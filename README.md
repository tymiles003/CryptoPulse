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
