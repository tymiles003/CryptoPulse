require 'logger'


class CoinTrader
  @@logger = Logger.new STDOUT

  def info msg
    @@logger.info msg
  end

  def trade(id, dry_run=true)
    success, details = _trade(id, dry_run)
    if not success
      raise RuntimeError, "Trade failed: #{details[0]}"
    end
    return details
  end

  private
    def _safe_market_buy(market, limit, dry_run)
      # Performs a "safe" market buy by looking at the top sell orders and executing a buy order
      # that is within that range
      # Returns quantity bought

      info "Checking sell market order book for #{market}"
      sell_orders = Bittrex::Order.book(market, :sell, Figaro.env.market_buy_threshold.to_i)
      # Inspect only the top sell orders. The "depth" parameter in the Bittrex API has a
      # bug where all of the sell orders are returned.
      # TODO: remove workaround when API is fixed
      sell_orders = sell_orders.first(Figaro.env.market_buy_threshold.to_i)

      begin
        #response = Bittrex::Order.limit_buy(market, quantity, rate)
      rescue RuntimeError => e
        return false, ["Could not buy BTC for trading due to exception: #{e}"]
      end
    end

    def _trade(id, dry_run)
      # Executes the trades for a given Dollar Cost Average config.
      # Returns true with an array of trades if successful.
      # Returns false with an array of error messages if not successful.
      info "Executing trade for config #{id}, dry_run=#{dry_run}"
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

      info "Validating we have enough USDT in our wallet"
      begin
        wallets =  Bittrex::Wallet.all
      rescue RuntimeError => e
        return false, ["Unable to retrieve wallet info from Bittrex: #{e}"]
      end
      usdt_wallet = wallets.detect {|wall| wall.currency == "USDT"}
      usd_balance = usdt_wallet.nil? ? 0 : usdt_wallet.available
      if usd_amount > usd_balance
        return false, ["Not enough USDT to transact. Amount required=$#{usd_amount}. Balance=$#{usd_balance}"]
      end

      # Turn USDT into BTC prior to trading (all cryptos exchange with BTC, but not USDT)
      begin
        btc_amount = _safe_market_buy 'USDT-BTC', usd_amount, dry_run
      rescue RuntimeError => e
        return false, ["Unable to market buy USDT-BTC: #{e}"]
      end

      '''
      alloc.each do |asset, contrib|
        asset = asset.downcase
        if asset == "btc"
          info "Skipping BTC allocation, already bought"
          next
        end

        info "Buying #{contrib}\% of #{asset}"
        trades.push({asset => contrib})
      end
      '''
      info "Trades completed."
      return true, trades
    end
end







