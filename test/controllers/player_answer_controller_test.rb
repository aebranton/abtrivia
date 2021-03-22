require "test_helper"

class PlayerAnswerControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    post submit_answer_path
    assert_response :no_content
  end
end
