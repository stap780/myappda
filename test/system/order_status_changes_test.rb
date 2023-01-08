require "application_system_test_case"

class OrderStatusChangesTest < ApplicationSystemTestCase
  setup do
    @order_status_change = order_status_changes(:one)
  end

  test "visiting the index" do
    visit order_status_changes_url
    assert_selector "h1", text: "Order Status Changes"
  end

  test "creating a Order status change" do
    visit order_status_changes_url
    click_on "New Order Status Change"

    fill_in "Client", with: @order_status_change.client_id
    fill_in "Event", with: @order_status_change.event_id
    fill_in "Insales custom status title", with: @order_status_change.insales_custom_status_title
    fill_in "Insales financial status", with: @order_status_change.insales_financial_status
    fill_in "Insales order", with: @order_status_change.insales_order_id
    fill_in "Insales order number", with: @order_status_change.insales_order_number
    click_on "Create Order status change"

    assert_text "Order status change was successfully created"
    click_on "Back"
  end

  test "updating a Order status change" do
    visit order_status_changes_url
    click_on "Edit", match: :first

    fill_in "Client", with: @order_status_change.client_id
    fill_in "Event", with: @order_status_change.event_id
    fill_in "Insales custom status title", with: @order_status_change.insales_custom_status_title
    fill_in "Insales financial status", with: @order_status_change.insales_financial_status
    fill_in "Insales order", with: @order_status_change.insales_order_id
    fill_in "Insales order number", with: @order_status_change.insales_order_number
    click_on "Update Order status change"

    assert_text "Order status change was successfully updated"
    click_on "Back"
  end

  test "destroying a Order status change" do
    visit order_status_changes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Order status change was successfully destroyed"
  end
end
