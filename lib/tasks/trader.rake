require_relative '../modules/coin_trader'

namespace :trader do

  def trade_helper(args, dry=true)
    ct = CoinTrader.new
    args.to_a.each do |id|
      report = {:errors=>[], :trades=>[]}
      begin
        ct.trade id, dry
      rescue RuntimeError => e
        puts "Exception while trading #{id}: #{e}"
        report[:errors].push e.to_s
      end
      puts "Final report for #{id}: #{report}"
    end
  end

  desc "Executes trades based on the configs' allocations"
  task :go, [:config_ids] => :environment do |task, args|
    trade_helper args, false
  end

  desc "Executes a dry run of trades based on the configs' allocations"
  task :dry, [:config_ids] => :environment do |task, args|
    trade_helper args, true
  end
end
