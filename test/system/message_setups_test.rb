require "application_system_test_case"

class MessageSetupsTest < ApplicationSystemTestCase
  setup do
    @message_setup = message_setups(:one)
  end

  test "visiting the index" do
    visit message_setups_url
    assert_selector "h1", text: "Message Setups"
  end

  test "creating a Message setup" do
    visit message_setups_url
    click_on "New Message Setup"

    fill_in "Description", with: @message_setup.description
    fill_in "Handle", with: @message_setup.handle
    fill_in "Payplan", with: @message_setup.payplan_id
    check "Status" if @message_setup.status
    fill_in "Title", with: @message_setup.title
    fill_in "Valid until", with: @message_setup.valid_until
    click_on "Create Message setup"

    assert_text "Message setup was successfully created"
    click_on "Back"
  end

  test "updating a Message setup" do
    visit message_setups_url
    click_on "Edit", match: :first

    fill_in "Description", with: @message_setup.description
    fill_in "Handle", with: @message_setup.handle
    fill_in "Payplan", with: @message_setup.payplan_id
    check "Status" if @message_setup.status
    fill_in "Title", with: @message_setup.title
    fill_in "Valid until", with: @message_setup.valid_until
    click_on "Update Message setup"

    assert_text "Message setup was successfully updated"
    click_on "Back"
  end

  test "destroying a Message setup" do
    visit message_setups_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Message setup was successfully destroyed"
  end
end
