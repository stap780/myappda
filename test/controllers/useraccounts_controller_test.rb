require 'test_helper'

class UseraccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @useraccount = useraccounts(:one)
  end

  test "should get index" do
    get useraccounts_url
    assert_response :success
  end

  test "should get new" do
    get new_useraccount_url
    assert_response :success
  end

  test "should create useraccount" do
    assert_difference('Useraccount.count') do
      post useraccounts_url, params: { useraccount: { email: @useraccount.email, insuserid: @useraccount.insuserid, name: @useraccount.name, shop: @useraccount.shop, user_id: @useraccount.user_id } }
    end

    assert_redirected_to useraccount_url(Useraccount.last)
  end

  test "should show useraccount" do
    get useraccount_url(@useraccount)
    assert_response :success
  end

  test "should get edit" do
    get edit_useraccount_url(@useraccount)
    assert_response :success
  end

  test "should update useraccount" do
    patch useraccount_url(@useraccount), params: { useraccount: { email: @useraccount.email, insuserid: @useraccount.insuserid, name: @useraccount.name, shop: @useraccount.shop, user_id: @useraccount.user_id } }
    assert_redirected_to useraccount_url(@useraccount)
  end

  test "should destroy useraccount" do
    assert_difference('Useraccount.count', -1) do
      delete useraccount_url(@useraccount)
    end

    assert_redirected_to useraccounts_url
  end
end
