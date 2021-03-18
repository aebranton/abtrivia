require "test_helper"

class TriviaSessionStateTest < ActiveSupport::TestCase
  def setup
    @trivia_session_state = TriviaSessionState.new(name: "Pending")
  end

  test "state should be valid and contain a name" do
    @trivia_session_state.valid?
  end
end
