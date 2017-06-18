require_relative '../modules/cointrader'

namespace :trader do

  desc "Executes trades based on the configs' allocations"
  task :go, [:config_ids] => :environment do |task, args|
    ct = CoinTrader.new
    args.to_a.each do |id|
      report = {:errors=>[], :trades=>[]}
      begin
        ct.trade id, false
      rescue RuntimeError => e
        puts "Exception while trading #{id}: #{e}"
        report[:errors].push e
      end
      puts "Final report for #{id}: #{report}"
    end
  end

  desc "Executes a dry run of trades based on the configs' allocations"
  task :dry, [:config_ids] => :environment do |task, args|
    ct = CoinTrader.new
    args.to_a.each do |id|
      report = {:errors=>[], :trades=>[]}
      begin
        ct.trade id
      rescue RuntimeError => e
        puts "Exception while trading #{id}: #{e}"
        report[:errors].push e.to_s
      end
      puts "Final report for #{id}: #{report}"
    end
  end
end
