def log_helper(report=nil, msg_type=nil, msg)
  # Saves a log of the trade status
  report[msg_type].push(msg) unless (not msg_type or not report)
  puts msg
end

namespace :trader do
  def trade_helper(config_ids, dry_run=true)
    report = {:trades=>[], :errors=>[]}
    puts "Executing trades #{config_ids}, dry_run=#{dry_run}"
    config_ids.each do |id|
      conf = Config.find_by_id(id)
      if conf.nil?
        log_helper report, :errors, "Invalid config #{id}."
        next
      end

      # Validate trade allocation
      log_helper(msg="Executing trades for #{id}, allocation=#{conf.allocation}, USD amount=$#{conf.amount}")
      alloc = JSON.parse(conf.allocation)
      if alloc.values.sum != 100
        log_helper report, :errors, "Invalid allocation for #{id}, doesn't add to '100', #{alloc}"
        next
      end

      # Validate contribution amount and that we have enough USDT
      amount = conf.amount
      if not amount
        log_helper report, :errors, "Invalid USD contribution amount for #{id}. Must be > $0.}"
        next
      end
      begin
        wallets =  Bittrex::Wallet.all
      rescue Exception => e
        log_helper report, :errors, "Unable to retrieve wallet info from Bittrex for #{id}: #{e}"
        next
      end
      usdt_wallet = wallets.detect {|wall| wall.currency == "USDT"}
      balance = usdt_wallet.nil? ? 0 : usdt_wallet.available
      if amount > balance
        log_helper report, :errors, "Not enough USDT to transact for #{id}. Amount required=$#{amount}. Balance=$#{balance}"
        next
      end

      # Execute each trade
      alloc.each do |asset, contrib|
        log_helper(msg="Buying #{contrib}\% of #{asset}")
        if asset.downcase != 'btc'
          log_helper(msg=Bittrex::Quote.current("BTC-#{asset}").ask)
        end
      end
    end

    puts "Trade completed, report=#{report}"
  end

  desc "Executes trades based on the configs' allocations"
  task :go, [:config_ids] => :environment do |task, args|
    trade_helper args.to_a, false
  end

  desc "Executes a dry run of trades based on the configs' allocations"
  task :dry, [:config_ids] => :environment do |task, args|
    trade_helper args.to_a
  end
end
