require "application_system_test_case"

class EventActionsTest < ApplicationSystemTestCase
  setup do
    @event_action = event_actions(:one)
  end

  test "visiting the index" do
    visit event_actions_url
    assert_selector "h1", text: "Event Actions"
  end

  test "creating a Event action" do
    visit event_actions_url
    click_on "New Event Action"

    fill_in "Event", with: @event_action.event_id
    check "Pause" if @event_action.pause
    fill_in "Pause time", with: @event_action.pause_time
    fill_in "Template", with: @event_action.template_id
    check "Timetable" if @event_action.timetable
    fill_in "Timetable time", with: @event_action.timetable_time
    fill_in "Type", with: @event_action.type
    click_on "Create Event action"

    assert_text "Event action was successfully created"
    click_on "Back"
  end

  test "updating a Event action" do
    visit event_actions_url
    click_on "Edit", match: :first

    fill_in "Event", with: @event_action.event_id
    check "Pause" if @event_action.pause
    fill_in "Pause time", with: @event_action.pause_time
    fill_in "Template", with: @event_action.template_id
    check "Timetable" if @event_action.timetable
    fill_in "Timetable time", with: @event_action.timetable_time
    fill_in "Type", with: @event_action.type
    click_on "Update Event action"

    assert_text "Event action was successfully updated"
    click_on "Back"
  end

  test "destroying a Event action" do
    visit event_actions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Event action was successfully destroyed"
  end
end
