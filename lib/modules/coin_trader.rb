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
    def _trade(id, dry_run)
      info "Executing trade for config #{id}, dry_run=#{dry_run}"
      trades = []
      conf = Config.find_by_id(id)
      if conf.nil?
        return false, ["Invalid config."]
      end

      # Validate trade allocation amount
      info "Allocation=#{conf.allocation}, USD amount=$#{conf.amount}"
      alloc = JSON.parse(conf.allocation)
      if alloc.values.sum != 100
        return false, ["Invalid allocation. doesn't add to '100', #{alloc}"]
      end

      # Validate the contribution amount
      amount = conf.amount
      if amount.nil? or amount == 0
        return false, ["Invalid USD contribution amount. Must be > $0.}"]
      end

      # Validate the currencies in our allocation
      begin
        bittrex_currencies = Bittrex::Currency.all
      rescue Exception => e
        return false, ["Unable to retrieve Bittrex currencies: #{e}"]
      end
      invalid_currencies = alloc.keys.select { |curr| bittrex_currencies.detect { |btrx_curr| btrx_curr.abbreviation == curr }.nil? }
      if invalid_currencies.any?
        return false, ["Allocation contains invalid currencies: #{invalid_currencies}"]
      end

      # Validate we have enough money in our wallet
      begin
        # Get all of the active wallets for this user
        wallets =  Bittrex::Wallet.all
      rescue Exception => e
        return false, ["Unable to retrieve wallet info from Bittrex: #{e}"]
      end
      # Get the USDT wallet and validate we have enough USDT
      usdt_wallet = wallets.detect {|wall| wall.currency == "USDT"}
      balance = usdt_wallet.nil? ? 0 : usdt_wallet.available
      if amount > balance
        return false, ["Not enough USDT to transact. Amount required=$#{amount}. Balance=$#{balance}"]
      end

      # Market buy enough BTC to execute all of our trades
      begin
        Bittrex::Order.market_buy('USDT-BTC', 1)
      rescue Exception => e
        return false, ["Could not buy BTC for trading: #{e}"]
      end

      # Execute each trade
      alloc.each do |asset, contrib|
        info "Buying #{contrib}\% of #{asset}"
        trades.push({asset => contrib})
      end
      info "Trades completed."
      trades
    end
end







