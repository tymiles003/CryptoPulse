# CryptoPulse

A dollar cost averaging cryptocurrency trading bot.

CryptoPulse executes periodic trades on the Bittrex exchange using a preset allocation that you set yourself.
It executes all trades using BTC pairs.

Note: __Use CryptoPulse at your own risk. It performs market buys on your behalf. And never leave coins on exchanges for long.__

## Setup
1. Install Rails on the server. Here's a guide for [Raspberry Pi](http://elinux.org/RPi_Ruby_on_Rails)
2. `gem install bundle`
3. `bundle install`
4. `bundle exec rake db:create db:migrate`
5. Add an application.yml file containing your Bittrex API key and secret:
    ```
    bittrex_api_key: "000"
    bittrex_api_secret: "000"
    ```
6. Make sure that your servers white list is set correctly in your Bittrex settings.
7. `bundle exec rails s`

## Running the test cases
1. `rspec` should return all passed results

## Data models
### Config - holds information about trade allocations
1. __amount__: amount of USD to invest, using a dollar cost averaging technique, on a weekly cadence
2. __allocation__: a JSON object with the desired asset allocation percentages. For example, `{"APX": 90, "ETH": 10}`
would buy roughly $90 worth of APX and $10 worth of ETH, if the trading amount is $100.
*Note*: The sum of the values in the JSON object must be no greater than 100 (since it's a percentage).

### Execution - holds information about an execution of a set of trades matching the desired Config
1. __config__: a foreign key to the config that was executed

### Order - holds information about a particular Bittrex order that was part of an Execution
1. __uuid__: the Bittrex UUID of the order
2. __execution__: a foreign key to the execution corresponding to this order
