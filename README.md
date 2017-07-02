# CryptoPulse

A dollar cost averaging cryptocurrency trading bot.

It's easy to dollar cost average into Bitcoin via exchanges like Coinbase, but it's not as easy to dollar cost average into a diverse set of altcoins. CryptoPulse executes periodic trades on the Bittrex exchange using a preset allocation that you set yourself.

All trades are executed using BTC pairs, so you need enough BTC in your Bittrex account to complete each trade.

Configure the whenever gem to execute trades at your own schedule.

Note: __Use CryptoPulse at your own risk. It performs market buys on your behalf. And never leave coins on exchanges for long.__

## Setup
1. Install Rails on the server. Here's a guide for [Raspberry Pi](http://elinux.org/RPi_Ruby_on_Rails).
    1. For RPI, I also needed to run `sudo apt-get install postgresql postgresql-contrib libpq-dev` before the `pg` gem would install.
2. If you're using a production database: modify `config/database.yml` to use the correct login/password.
3. `gem install bundle`
4. `bundle install`
5. `bundle exec rake db:create db:migrate`
6. Configure CryptoPulse as outlined below

## Configuring
1. Add a `config/application.yml` file containing your Bittrex API key and secret:
    ```
    bittrex_api_key: "000"
    bittrex_api_secret: "000"
    ```
2. Configure `config/schedule.rb` and use [whenever](https://github.com/javan/whenever) to update your servers crontabs to automatically execute trades. This repo contains a sample configuration to automatically execute a trade every monday at midnight.
3. (Optional): To perform dry runs (i.e. no actual trades are made, and no db entries are written):
    ```
    dry_run: "true"
    ```

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
