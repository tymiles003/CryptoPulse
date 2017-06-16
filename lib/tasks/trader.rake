namespace :trader do
  desc "Executes trades based on the configs' allocations"
  task :go, [:config_ids] => :environment do |task, args|
  end

  desc "Executes a dry run of trades based on the configs' allocations"
  task :dry, [:config_ids] => :environment do |task, args|
  end
end
