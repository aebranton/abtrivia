require "test_helper"

class LoginsControllerTest < ActionDispatch::IntegrationTest

  def setup 
    post login_path, params: {email: "ae.branton9@gmail.com"}
  end

  test "should get new" do
    get login_path
    assert_response :ok
  end

  test "should get create" do
    post login_path
    assert_response :found
  end

  test "should get destroy" do
    get logout_path
    assert_response :found
  end
end
