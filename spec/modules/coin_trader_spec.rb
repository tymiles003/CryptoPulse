require 'rails_helper'
require 'coin_trader'

describe CoinTrader, :module do
  include_context "db_cleanup", :transaction
  before(:all) do
    @coin_trader = CoinTrader.new
    @config = FactoryGirl.create(:config)
  end
  let(:config) { Config.find(@config.id) }
  let(:coin_trader) { @coin_trader }

  context "given an invalid Config" do
    it "when config id doesn't exist" do 
      expect{ coin_trader.trade(1000) }.to raise_error(RuntimeError) 
    end

    it "raises an error on an invalid asset allocation" do
      conf_invalid_alloc = Config.create(
        :allocation=>{:BTC=>101}.to_json,
        :amount=>100)
      expect{ coin_trader.trade(conf_invalid_alloc.id) }.to raise_error(RuntimeError)
    end

    it "raises an error on an invalid contribution amount" do
      conf_invalid_contrib = Config.create(
        :allocation=>{:BTC=>100}.to_json,
        :amount=>0)
      expect{ coin_trader.trade(conf_invalid_contrib.id) }.to raise_error(RuntimeError)
    end

    it "raises an error when Bittrex doesn't have an exchange for a desired currency" do
      conf_no_exchange = Config.create(
        :allocation=>{:BTCXDDD=>100}.to_json,
        :amount=>100)
      expect{ coin_trader.trade(conf_no_exchange.id) }.to raise_error(RuntimeError)
    end

    it "raises an error when we don't have enough USDT to exchange" do
      conf_no_money = Config.create(
        :allocation=>{:BTC=>100}.to_json,
        :amount=>1000)
      expect{ coin_trader.trade(conf_no_money.id) }.to raise_error(RuntimeError)
    end

    it "raises an error when BTC market buying fails" do
      # Sinatra should raise an error that market buying is turned off.
      # This command will fail indefinitely, since Bittrex has turned this off from site.
      expect{ coin_trader.trade(config.id) }.to raise_error(RuntimeError)
    end
  end
end
