require 'rails_helper'

describe Config, :model do
  include_context "db_cleanup", :transaction
  before(:all) do
    @config = FactoryGirl.create(:config)
  end
  let(:config) { Config.find(@config.id) }

  context "created Config" do
    it { expect(config).to be_persisted }
    it { expect(config.allocation).to_not be_nil }
    it { expect(config.created_at).to_not be_nil }
    it { expect(config.updated_at).to_not be_nil }
  end

end
