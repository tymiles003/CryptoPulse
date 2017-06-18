require 'sinatra/base'

class FakeBittrex < Sinatra::Base
  @@public_prefix = '/api/v1.1/public/'
  @@account_prefix = '/api/v1.1/account/'
  def self.public_prefix
    @@public_prefix
  end

  def self.account_prefix
    @@account_prefix
  end

  get "#{public_prefix}getcurrencies" do
    json_response 200, 'currencies.json'
  end

  get "#{account_prefix}getbalances*" do
    json_response 200, 'balances.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
