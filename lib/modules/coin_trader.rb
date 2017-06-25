require 'logger'


class CoinTrader
  @@logger = Logger.new STDOUT

  def info msg
    @@logger.info msg
  end

  def markets
    if @markets.nil?
      @markets = Bittrex::Summary.all
    end
    @markets
  end

  def get_market(mkt_name)
    markets.detect {|mkt| mkt.name == mkt_name}
  end

  def wallets
    if @wallets.nil?
      @wallets = Bittrex::Wallet.all
    end
    @wallets
  end    

  def trade(id)
    success = false
    begin
      success, details = _trade(id)
    rescue Exception => e
      details = ["Uncaught exception: #{e}"]
    end
    if not success
      msg = "Trade failed: #{details[0]}"
      info msg
      raise RuntimeError, msg
    end
    return details
  end

  private
    def _convert_currency(from_amt, from_curr, to_curr)
      # Converts a currency from one amount to another
      info "Converting #{from_amt} #{from_curr} to #{to_curr}"

      # Check both pairs (eg. "USDT-BTC" and "BTC-USDT" to see which exists)
      market_name = "#{from_curr.upcase}-#{to_curr.upcase}"
      market = get_market market_name
      return market.last / from_amt if market
      market_name = "#{to_curr.upcase}-#{from_curr.upcase}"
      market = get_market market_name
      return market.last * from_amt if market
      info "Unable to find market for exchange"
      nil
    end

    def _market_buy(market_name, limit)
      # Performs a "naive" market buy by executing a limit buy based on the Ask price
      info "Executing market buy for #{market_name}: #{limit}.}"

      market_name = "BTC-#{market_name.upcase}"
      market = get_market market_name
      rate = market.raw['Ask']
      quantity = limit / rate

      info "Buying #{quantity} of #{market_name} at #{rate}"
      response = Bittrex::Order.limit_buy(market_name, quantity, rate)
    end

    def _trade(id)
      # Executes the trades for a given Dollar Cost Average config.
      # Returns true with an array of trades if successful.
      # Returns false with an array of error messages if not successful.
      info "Executing trade for config #{id}"
      trades = []

      info "Validating that the config exists"
      conf = Config.find_by_id(id)
      if conf.nil?
        return false, ["Invalid config."]
      end

      info "Validating trade allocation=#{conf.allocation}"
      alloc = JSON.parse(conf.allocation)
      if alloc.values.sum > 100
        return false, ["Invalid allocation. doesn't add to '100', #{alloc}"]
      end

      info "Validating contribution amount=$#{conf.amount}"
      usd_amount = conf.amount
      if usd_amount.nil? or usd_amount == 0
        return false, ["Invalid USD contribution amount. Must be > $0.}"]
      end

      info "Validating allocated currencies trade in Bittrex"
      begin
        bittrex_currencies = Bittrex::Currency.all
      rescue RuntimeError => e
        return false, ["Unable to retrieve Bittrex currencies: #{e}"]
      end
      invalid_currencies = alloc.keys.select { |curr| bittrex_currencies.detect { |btrx_curr| btrx_curr.abbreviation == curr }.nil? }
      if invalid_currencies.any?
        return false, ["Allocation contains invalid currencies: #{invalid_currencies}"]
      end

      info "Validating we have enough BTC in our wallet for a #{usd_amount} contribution"
      btc_wallet = wallets.detect {|wall| wall.currency == "BTC"}
      btc_balance = btc_wallet.nil? ? 0 : btc_wallet.available
      usd_balance = _convert_currency(btc_balance, "BTC", "USDT")
      if usd_balance.nil? or usd_amount > usd_balance
        return false, ["Not enough USDT to transact. Amount required=$#{usd_amount}. Balance=$#{usd_balance} (#{btc_balance} BTC)"]
      end

      alloc.each do |asset, contrib|
        amount_btc = btc_balance * (contrib.to_f/100)
        info "Buying #{amount_btc} BTC worth of #{asset}"
        begin
          _market_buy asset, amount_btc
        rescue RuntimeError => e
          return false, ["Unable to market buy #{asset} for #{amount_btc}"]
        end
      end
      info "Trades completed."
      return true, trades
    end
end







