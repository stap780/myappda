require 'test_helper'

class EmailSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email_setup = email_setups(:one)
  end

  test "should get index" do
    get email_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_email_setup_url
    assert_response :success
  end

  test "should create email_setup" do
    assert_difference('EmailSetup.count') do
      post email_setups_url, params: { email_setup: { address: @email_setup.address, authentication: @email_setup.authentication, domain: @email_setup.domain, port: @email_setup.port, tls: @email_setup.tls, user_name: @email_setup.user_name, user_password: @email_setup.user_password } }
    end

    assert_redirected_to email_setup_url(EmailSetup.last)
  end

  test "should show email_setup" do
    get email_setup_url(@email_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_setup_url(@email_setup)
    assert_response :success
  end

  test "should update email_setup" do
    patch email_setup_url(@email_setup), params: { email_setup: { address: @email_setup.address, authentication: @email_setup.authentication, domain: @email_setup.domain, port: @email_setup.port, tls: @email_setup.tls, user_name: @email_setup.user_name, user_password: @email_setup.user_password } }
    assert_redirected_to email_setup_url(@email_setup)
  end

  test "should destroy email_setup" do
    assert_difference('EmailSetup.count', -1) do
      delete email_setup_url(@email_setup)
    end

    assert_redirected_to email_setups_url
  end
end
