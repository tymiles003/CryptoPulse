FactoryGirl.define do
  factory :config_faker, class: 'Config' do
    allocation { {:BTC=>80, :APX=>20}.to_json }
  end

  factory :config, :parent=>:config_faker do
  end
end
