Bittrex.config do |c|
  c.key = Figaro.env.bittrex_api_key
  c.secret = Figaro.env.bittrex_api_secret
end

Bittrex::Client
class Bittrex::Client
  def get_full(path, params = {}, headers = {})
    # This is identical to the Bittrex::Client::get function, 
    # but it returns the full response
    nonce = Time.now.to_i
    response = connection.get do |req|
      url = "#{HOST}/#{path}"
      req.params.merge!(params)
      req.url(url)

      if key
        req.params[:apikey]   = key
        req.params[:nonce]    = nonce
        req.headers[:apisign] = signature(url, nonce)
      end
    end

    JSON.parse(response.body)
  end
end

Bittrex::Wallet
class Bittrex::Wallet
  def self.all
    # Fix a bug in the current Bittrex gem
    # client.get('account/getbalances').values.map{|data| new(data) }
    client.get('account/getbalances').map{|data| new(data) }
  end
end

Bittrex::Order
class Bittrex::Order
  def self.market_buy(market, quantity)
    client.get_full('market/buymarket', market: market, quantity: quantity)
  end
end
