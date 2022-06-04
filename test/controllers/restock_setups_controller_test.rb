require 'test_helper'

class RestockSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restock_setup = restock_setups(:one)
  end

  test "should get index" do
    get restock_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_restock_setup_url
    assert_response :success
  end

  test "should create restock_setup" do
    assert_difference('RestockSetup.count') do
      post restock_setups_url, params: { restock_setup: { description: @restock_setup.description, handle: @restock_setup.handle, status: @restock_setup.status, title: @restock_setup.title } }
    end

    assert_redirected_to restock_setup_url(RestockSetup.last)
  end

  test "should show restock_setup" do
    get restock_setup_url(@restock_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_restock_setup_url(@restock_setup)
    assert_response :success
  end

  test "should update restock_setup" do
    patch restock_setup_url(@restock_setup), params: { restock_setup: { description: @restock_setup.description, handle: @restock_setup.handle, status: @restock_setup.status, title: @restock_setup.title } }
    assert_redirected_to restock_setup_url(@restock_setup)
  end

  test "should destroy restock_setup" do
    assert_difference('RestockSetup.count', -1) do
      delete restock_setup_url(@restock_setup)
    end

    assert_redirected_to restock_setups_url
  end
end
