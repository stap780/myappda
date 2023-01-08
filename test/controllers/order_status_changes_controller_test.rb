require 'test_helper'

class OrderStatusChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order_status_change = order_status_changes(:one)
  end

  test "should get index" do
    get order_status_changes_url
    assert_response :success
  end

  test "should get new" do
    get new_order_status_change_url
    assert_response :success
  end

  test "should create order_status_change" do
    assert_difference('OrderStatusChange.count') do
      post order_status_changes_url, params: { order_status_change: { client_id: @order_status_change.client_id, event_id: @order_status_change.event_id, insales_custom_status_title: @order_status_change.insales_custom_status_title, insales_financial_status: @order_status_change.insales_financial_status, insales_order_id: @order_status_change.insales_order_id, insales_order_number: @order_status_change.insales_order_number } }
    end

    assert_redirected_to order_status_change_url(OrderStatusChange.last)
  end

  test "should show order_status_change" do
    get order_status_change_url(@order_status_change)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_status_change_url(@order_status_change)
    assert_response :success
  end

  test "should update order_status_change" do
    patch order_status_change_url(@order_status_change), params: { order_status_change: { client_id: @order_status_change.client_id, event_id: @order_status_change.event_id, insales_custom_status_title: @order_status_change.insales_custom_status_title, insales_financial_status: @order_status_change.insales_financial_status, insales_order_id: @order_status_change.insales_order_id, insales_order_number: @order_status_change.insales_order_number } }
    assert_redirected_to order_status_change_url(@order_status_change)
  end

  test "should destroy order_status_change" do
    assert_difference('OrderStatusChange.count', -1) do
      delete order_status_change_url(@order_status_change)
    end

    assert_redirected_to order_status_changes_url
  end
end
