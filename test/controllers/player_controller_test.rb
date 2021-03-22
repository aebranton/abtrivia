require "test_helper"

class PlayerControllerTest < ActionDispatch::IntegrationTest
  def setup 
    post login_path, params: {email: "ae.branton9@gmail.com"}
  end

  test "should get create" do
    post register_path, params: {player: {email: "ae.branton9@gmail.com", display_name: "Test"}}
    assert_response :found
  end

  test "should get new" do
    get register_path
    assert_response :ok
  end

  test "should get show" do
    get player_history_path
    assert_response :found
  end
end
