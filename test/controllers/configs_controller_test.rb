require 'test_helper'

class ConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @config = configs(:one)
  end

  test "should get index" do
    get configs_url, as: :json
    assert_response :success
  end

  test "should create config" do
    assert_difference('Config.count') do
      post configs_url, params: { config: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show config" do
    get config_url(@config), as: :json
    assert_response :success
  end

  test "should update config" do
    patch config_url(@config), params: { config: {  } }, as: :json
    assert_response 200
  end

  test "should destroy config" do
    assert_difference('Config.count', -1) do
      delete config_url(@config), as: :json
    end

    assert_response 204
  end
end
