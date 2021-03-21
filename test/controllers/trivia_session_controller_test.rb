require "test_helper"

class TriviaSessionControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get trivia_session_new_url
    assert_response :success
  end

  test "should get create" do
    get trivia_session_create_url
    assert_response :success
  end

  test "should get show" do
    get trivia_session_show_url
    assert_response :success
  end
end
