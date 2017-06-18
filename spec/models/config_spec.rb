require 'rails_helper'

describe Config, :model do
  include_context "db_cleanup", :transaction
  before(:all) do
    @config = FactoryGirl.create(:config)
  end
  let(:config) { Config.find(@config.id) }

  context "given a valid Config" do
    it "is persisted" do
      expect(config).to be_persisted
    end
    it "has a non-nil allocation" do
      expect(config.allocation).to_not be_nil
    end
    it "has a created_at" do 
      expect(config.created_at).to_not be_nil
    end
    it "has an updated_at" do
      expect(config.updated_at).to_not be_nil
    end
    it "has an allocation" do 
      expect(config.allocation).to eq(@config.allocation)
    end
    it "has a JSON-parsable allocation" do
      expect(config.allocation).to eq(@config.allocation)
      expect { JSON.parse(config.allocation).to_not raise_error}
    end
  end
end
