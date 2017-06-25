FactoryGirl.define do
  factory :config_faker, class: 'Config' do
    allocation { {:ZEC=>50, :STRAT=>50}.to_json }
    amount { 100 }
  end

  factory :config, :parent=>:config_faker do
  end
end
