require 'test_helper'

class EventActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_action = event_actions(:one)
  end

  test "should get index" do
    get event_actions_url
    assert_response :success
  end

  test "should get new" do
    get new_event_action_url
    assert_response :success
  end

  test "should create event_action" do
    assert_difference('EventAction.count') do
      post event_actions_url, params: { event_action: { event_id: @event_action.event_id, pause: @event_action.pause, pause_time: @event_action.pause_time, template_id: @event_action.template_id, timetable: @event_action.timetable, timetable_time: @event_action.timetable_time, type: @event_action.type } }
    end

    assert_redirected_to event_action_url(EventAction.last)
  end

  test "should show event_action" do
    get event_action_url(@event_action)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_action_url(@event_action)
    assert_response :success
  end

  test "should update event_action" do
    patch event_action_url(@event_action), params: { event_action: { event_id: @event_action.event_id, pause: @event_action.pause, pause_time: @event_action.pause_time, template_id: @event_action.template_id, timetable: @event_action.timetable, timetable_time: @event_action.timetable_time, type: @event_action.type } }
    assert_redirected_to event_action_url(@event_action)
  end

  test "should destroy event_action" do
    assert_difference('EventAction.count', -1) do
      delete event_action_url(@event_action)
    end

    assert_redirected_to event_actions_url
  end
end
