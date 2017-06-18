require 'rails_helper'
require 'cointrader'

describe CoinTrader, :module do
  include_context "db_cleanup", :transaction
  before(:all) do
    @coin_trader = CoinTrader.new
    @config = FactoryGirl.create(:config)
  end
  let(:config) { Config.find(@config.id) }
  let(:coin_trader) { @coin_trader }

  context "executes Trades" do
    it { 
      coin_trader.trade(config.id) 
    }
  end
end
