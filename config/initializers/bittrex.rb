Bittrex.config do |c|
  c.key = Figaro.env.bittrex_api_key
  c.secret = Figaro.env.bittrex_api_secret
end

Bittrex::Wallet
class Bittrex::Wallet
  def self.all
    # Fix a bug in the current Bittrex gem
    # client.get('account/getbalances').values.map{|data| new(data) }
    client.get('account/getbalances').map{|data| new(data) }
  end
end
