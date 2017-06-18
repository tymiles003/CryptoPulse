# CryptoPulse

A dollar cost averaging cryptocurrency trading bot. 

CryptoPulse executes periodic trades on the Bittrex exchange using a preset allocation that you set yourself. 
It converts USDT to Bitcoin in order to execute trades using BTC pairs.

Note: __Use CryptoPulse at your own risk. It performs market buys on your behalf. And never leave coins on exchanges for long.__

## Setup
1. Install Rails
2. `bundle Install`
3. `bundle exec rake db:create db:migrate`
4. Add an application.yml file containing your Bittrex API key and secret:
    ```
    bittrex_api_key: "000"
    bittrex_api_secret: "000"
    ```
5. Make sure that your servers white list is set correctly in your Bittrex settings.
6. `bundle exec rails s`

## Data models
### Config
1. __amount__: amount of USD to invest, using a dollar cost averaging technique, on a weekly cadence
2. __allocation__: a JSON object with the desired asset allocation percentages. For example, `{"BTC": 90, "ETH": 10}`
would buy roughly $90 worth of BTC and $10 worth of ETH, if the trading amount is $100.
*Note*: The sum of the values in the JSON object must be no greater than 100 (since it's a percentage).
If the allocation is less than 100, CryptoPulse will fill in the gaps with BTC. For example, `{"ZEC": 10}`
would buy $10 worth of ZEC and $90 worth of BTC, if the trading amount is $100

### Order
1. __uuid__: the Bittrex UUID of orders we've placed
