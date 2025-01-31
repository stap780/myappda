require "application_system_test_mycase"

class MyasesTest < ApplicationSystemTestMycase
  setup do
    @mycase = mycases(:one)
  end

  test "visiting the index" do
    visit mycases_url
    assert_selector "h1", text: "mycases"
  end

  test "creating a mycase" do
    visit mycases_url
    click_on "New mycase"

    fill_in "Mycasetype", with: @mycase.mycasetype
    fill_in "Client", with: @mycase.client_id
    fill_in "Number", with: @mycase.number
    click_on "Create mycase"

    assert_text "mycase was successfully created"
    click_on "Back"
  end

  test "updating a mycase" do
    visit mycases_url
    click_on "Edit", match: :first

    fill_in "mycasetype", with: @mycase.mycasetype
    fill_in "Client", with: @mycase.client_id
    fill_in "Number", with: @mycase.number
    click_on "Update mycase"

    assert_text "mycase was successfully updated"
    click_on "Back"
  end

  test "destroying a mycase" do
    visit mycases_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "mycase was successfully destroyed"
  end
end
