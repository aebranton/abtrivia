require "test_helper"

class TriviaSessionTest < ActiveSupport::TestCase
  def setup
    category = QuestionCategory.new(name: "Test")
    question = Question.new(question_category: category, question: "Willl these tests pass?")
    answer = Answer.new(question: question, answer: "I bloody hope so!")
    player = Player.new(display_name: "Alex Branton", email: "ae.branton9@gmail.com")
    trivia_session_state = TriviaSessionState.new(name: "Pending")
    @trivia_session = TriviaSession.new(player: player, trivia_session_state: trivia_session_state, name: "Test Session")
  end

  test "trivia session should be valid" do
    assert @trivia_session.valid?
  end

  test "trivia session should be linked to a player" do
    @trivia_session.player = nil
    assert_not @trivia_session.valid?
  end

  test "trivia session should be linked to a session state" do
    @trivia_session.trivia_session_state = nil
    assert_not @trivia_session.valid?
  end

  test "trivia session name should not be too short" do
    @trivia_session.name = "tttt"
    assert_not @trivia_session.valid?
  end

  test "trivia session name should not be too long" do
    @trivia_session.name = "t" * 101
    assert_not @trivia_session.valid?
  end

end
