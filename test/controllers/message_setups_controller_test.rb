require 'test_helper'

class MessageSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message_setup = message_setups(:one)
  end

  test "should get index" do
    get message_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_message_setup_url
    assert_response :success
  end

  test "should create message_setup" do
    assert_difference('MessageSetup.count') do
      post message_setups_url, params: { message_setup: { description: @message_setup.description, handle: @message_setup.handle, payplan_id: @message_setup.payplan_id, status: @message_setup.status, title: @message_setup.title, valid_until: @message_setup.valid_until } }
    end

    assert_redirected_to message_setup_url(MessageSetup.last)
  end

  test "should show message_setup" do
    get message_setup_url(@message_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_message_setup_url(@message_setup)
    assert_response :success
  end

  test "should update message_setup" do
    patch message_setup_url(@message_setup), params: { message_setup: { description: @message_setup.description, handle: @message_setup.handle, payplan_id: @message_setup.payplan_id, status: @message_setup.status, title: @message_setup.title, valid_until: @message_setup.valid_until } }
    assert_redirected_to message_setup_url(@message_setup)
  end

  test "should destroy message_setup" do
    assert_difference('MessageSetup.count', -1) do
      delete message_setup_url(@message_setup)
    end

    assert_redirected_to message_setups_url
  end
end
