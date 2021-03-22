require "test_helper"

class TriviaSessionControllerTest < ActionDispatch::IntegrationTest
  def setup 
    post login_path, params: {email: "ae.branton9@gmail.com"}
  end

  test "should get new" do
    get trivia_session_new_path
    assert_response :found
  end

  test "should get create" do
    get trivia_session_create_path
    assert_response :found
  end

  test "should get show" do
    get trivia_session_show_path
    assert_response :ok
  end
end
