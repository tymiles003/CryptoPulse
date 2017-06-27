require_relative '../modules/coin_trader'

namespace :trader do
  desc "Executes trades based on the configs' allocations"
  task :go, [:config_ids] => :environment do |task, args|
    ct = CoinTrader.new
    args.to_a.each do |id|
      trades = nil
      begin
        trades = ct.trade id
      rescue RuntimeError => e
        puts "Exception while trading #{id}: #{e}"
      end
      puts "Executed trades: #{trades}"
    end
  end
end
