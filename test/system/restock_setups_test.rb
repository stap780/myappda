require "application_system_test_case"

class RestockSetupsTest < ApplicationSystemTestCase
  setup do
    @restock_setup = restock_setups(:one)
  end

  test "visiting the index" do
    visit restock_setups_url
    assert_selector "h1", text: "Restock Setups"
  end

  test "creating a Restock setup" do
    visit restock_setups_url
    click_on "New Restock Setup"

    fill_in "Description", with: @restock_setup.description
    fill_in "Handle", with: @restock_setup.handle
    check "Status" if @restock_setup.status
    fill_in "Title", with: @restock_setup.title
    click_on "Create Restock setup"

    assert_text "Restock setup was successfully created"
    click_on "Back"
  end

  test "updating a Restock setup" do
    visit restock_setups_url
    click_on "Edit", match: :first

    fill_in "Description", with: @restock_setup.description
    fill_in "Handle", with: @restock_setup.handle
    check "Status" if @restock_setup.status
    fill_in "Title", with: @restock_setup.title
    click_on "Update Restock setup"

    assert_text "Restock setup was successfully updated"
    click_on "Back"
  end

  test "destroying a Restock setup" do
    visit restock_setups_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Restock setup was successfully destroyed"
  end
end
