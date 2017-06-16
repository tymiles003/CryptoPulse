namespace :trader do
  def trade_helper(config_ids, dry_run=true)
    puts "Executing trades #{config_ids}, dry_run=#{dry_run}"
    config_ids.each do |id|
      conf = Config.find_by_id(id)
      if conf.nil?
        puts "Invalid config #{id}, trying next one."
        next
      end

      puts "Executing trades for #{id}, allocation=#{conf.allocation}"
      alloc = JSON.parse(conf.allocation)
      if alloc.values.sum != 100
        puts "Invalid allocation doesn't add to '100', #{alloc}, trying next one."
        next
      end

      alloc.each do |asset, contrib|
        puts "Buying #{contrib}\% of #{asset}"
      end
    end
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
