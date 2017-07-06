require 'logger'
require_relative 'bittrex'


class Float
  def floor2(exp = 0)
    # Taken from example here: https://richonrails.com/articles/rounding-numbers-in-ruby
    multiplier = 10 ** exp
    ((self * multiplier).floor).to_f/multiplier.to_f
  end
end


class CoinTrader
  @@logger = Logger.new STDOUT

  def info msg
    @@logger.info msg
  end

  def bittrex
    if @bittrex.nil?
      @bittrex = Bittrex
    end
    @bittrex
  end

  def currencies
    if @currencies.nil?
      @currencies = bittrex.currencies
      raise "Unable to get currencies from Bittrex: #{@currencies['message']}" if not @currencies['success']
    end
    @currencies['result']
  end

  def markets
    if @markets.nil?
      @markets = bittrex.market_summaries
      raise "Unable to get market summaries from Bittrex: #{@markets['message']}" if not @markets['success']
    end
    @markets['result']
  end

  def get_market(mkt_name)
    markets.detect {|mkt| mkt['MarketName'] == mkt_name}
  end

  def balances
    if @balances.nil?
      @balances = bittrex.balances
      raise "Unable to get balances from Bittrex: #{@balances['message']}" if not @balances['success']
    end
    @balances['result']
  end

  def trade(id)
    _trade(id)
  end

  private
  def _convert_currency(from_amt, from_curr, to_curr)
    # Converts a currency from one amount to another
    info "Converting #{from_amt} #{from_curr} to #{to_curr}"

    raise "Cannot convert currency when both types are identical" if from_curr == to_curr
    # Check both pairs (eg. "USDT-BTC" and "BTC-USDT" to see which exists)
    market_name = "#{from_curr.upcase}-#{to_curr.upcase}"
    market = get_market market_name
    return from_amt / market['Last'] if market
    market_name = "#{to_curr.upcase}-#{from_curr.upcase}"
    market = get_market market_name
    return market['Last'] * from_amt if market
    info "Unable to find market for exchange"
    nil
  end

  def _market_buy(market_name, limit)
    # Performs a "naive" market buy by executing a limit buy based on the Ask price
    # Returns the UUID of the order
    market_name = "BTC-#{market_name.upcase}"
    info "Executing market buy for #{market_name}: #{limit}."

    market = get_market market_name

    # Limit the Bittrex purchases to 8 decimal points
    rate = market['Ask'].floor2(8)
    quantity = (limit / rate).floor2(8)

    info "Buying #{quantity} of #{market_name} at #{rate} BTC"
    if Figaro.env.dry_run
      return
    end
    resp = bittrex.buy_limit(market_name, quantity, rate)
    raise "Limit buy order not successful. Resp = #{resp}" if not resp or not resp['success']
    return resp['result']['uuid']
  end

  def _trade(id)
    # Executes the trades for a given Dollar Cost Average config.
    # Returns true with an array of trades if successful.
    # Returns false with an array of error messages if not successful.
    info "Executing trade for config #{id}"

    info "Validating that the config exists"
    conf = Config.find_by_id(id)
    raise "Invalid config." if conf.nil?

    info "Validating trade allocation=#{conf.allocation}"
    alloc = JSON.parse(conf.allocation)
    raise "Invalid allocation. doesn't add to '100', #{alloc}" if alloc.values.sum > 100

    info "Validating contribution amount=$#{conf.amount}"
    usd_amount = conf.amount
    raise "Invalid USD contribution amount. Must be > $0" if usd_amount.nil? or usd_amount == 0

    info "Validating allocated currencies trade in Bittrex"
    invalid_currencies = alloc.keys.select { |curr| currencies.detect { |btrx_curr| btrx_curr['Currency'] == curr }.nil? }
    raise "Allocation contains invalid currencies: #{invalid_currencies}" if invalid_currencies.any?

    info "Validating we have enough BTC in our wallet for a $#{usd_amount} contribution"
    btc_amount = _convert_currency(usd_amount, 'USDT', 'BTC')
    info "$#{usd_amount} = #{btc_amount} BTC"
    btc_wallet = balances.detect {|wall| wall['Currency'] == 'BTC'}
    btc_balance = btc_wallet.nil? ? 0 : btc_wallet['Balance']
    usd_balance = _convert_currency(btc_balance, 'BTC', 'USDT')
    info "Wallet contains #{btc_balance}BTC ($#{usd_balance}). BTC required: #{btc_amount}"
    raise "Not enough BTC to transact. Amount required=#{btc_amount}BTC.
      Balance=#{btc_balance} BTC ($#{usd_balance} USD)" if btc_balance.nil? or btc_amount > btc_balance

    # Create an execution for this set of trades in the db
    exc = conf.executions.create unless Figaro.env.dry_run
    orders = []

    alloc.each do |asset, contrib|
      raise "Cannot buy BTC with BTC" if asset.upcase == 'BTC'

      amount = btc_amount * (contrib.to_f/100)
      uuid = _market_buy(asset, amount)
      order = exc.orders.create(:uuid=>uuid) unless Figaro.env.dry_run
      orders.push(order.uuid) unless Figaro.env.dry_run
    end
    info "Trades completed: #{orders}."
    orders
  end
end







