# Contains bittrex gem configuration and bug fixes

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
  def initialize(attrs = {})
    @id = attrs['Id'] || attrs['OrderUuid']
    @type = (attrs['Type'] || attrs['OrderType']).to_s.capitalize
    @exchange = attrs['Exchange']
    @quantity = attrs['Quantity']
    @remaining = attrs['QuantityRemaining']
    @price = attrs['Rate'] || attrs['Price']
    @total = attrs['Total']
    @fill = attrs['FillType']
    @limit = attrs['Limit']
    @commission = attrs['Commission']
    @raw = attrs
    # Override the official version with a small tweak to this line
    @executed_at = attrs.key?('TimeStamp') ? Time.parse(attrs['TimeStamp']) : nil
  end

  def self.limit_buy(market, quantity, rate)
    client.get_full(
      'market/buylimit', market: market, quantity: quantity, rate: rate)
  end
end
