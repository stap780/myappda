require "application_system_test_case"

class EmailSetupsTest < ApplicationSystemTestCase
  setup do
    @email_setup = email_setups(:one)
  end

  test "visiting the index" do
    visit email_setups_url
    assert_selector "h1", text: "Email Setups"
  end

  test "creating a Email setup" do
    visit email_setups_url
    click_on "New Email Setup"

    fill_in "Address", with: @email_setup.address
    fill_in "Authentication", with: @email_setup.authentication
    fill_in "Domain", with: @email_setup.domain
    fill_in "Port", with: @email_setup.port
    check "Tls" if @email_setup.tls
    fill_in "User name", with: @email_setup.user_name
    fill_in "User password", with: @email_setup.user_password
    click_on "Create Email setup"

    assert_text "Email setup was successfully created"
    click_on "Back"
  end

  test "updating a Email setup" do
    visit email_setups_url
    click_on "Edit", match: :first

    fill_in "Address", with: @email_setup.address
    fill_in "Authentication", with: @email_setup.authentication
    fill_in "Domain", with: @email_setup.domain
    fill_in "Port", with: @email_setup.port
    check "Tls" if @email_setup.tls
    fill_in "User name", with: @email_setup.user_name
    fill_in "User password", with: @email_setup.user_password
    click_on "Update Email setup"

    assert_text "Email setup was successfully updated"
    click_on "Back"
  end

  test "destroying a Email setup" do
    visit email_setups_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Email setup was successfully destroyed"
  end
end
