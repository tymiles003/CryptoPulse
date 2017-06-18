require 'sinatra/base'

class FakeBittrex < Sinatra::Base
  @@prefix = '/api/v1.1/'
  @@public_prefix = "#{@@prefix}public/"
  @@account_prefix = "#{@@prefix}account/"
  @@market_prefix = "#{@@prefix}market/"

  def self.public_prefix
    @@public_prefix
  end

  def self.account_prefix
    @@account_prefix
  end

  def self.market_prefix
    @@market_prefix
  end

  get "#{public_prefix}getcurrencies" do
    json_response 200, 'currencies.json'
  end

  get "#{account_prefix}getbalances*" do
    json_response 200, 'balances.json'
  end

  get "#{account_prefix}getbalances*" do
    json_response 200, 'balances.json'
  end

  get "#{market_prefix}buymarket*" do
    json_response 200, 'marketbuy_disabled.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
