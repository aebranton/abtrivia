require "test_helper"

class PlayerAnswerTest < ActiveSupport::TestCase
  def setup
    category = QuestionCategory.new(name: "Test")
    question = Question.new(question_category: category, question: "Willl these tests pass?")
    answer = Answer.new(question: question, answer: "I bloody hope so!")
    player = Player.new(display_name: "Alex Branton", email: "ae.branton9@gmail.com")
    trivia_session_state = TriviaSessionState.new(name: "Pending")
    trivia_session = TriviaSession.new(player: player, trivia_session_state: trivia_session_state, name: "Test Session")
    @player_answer = PlayerAnswer.new(answer: answer, player: player, trivia_session: trivia_session)
  end

  test "answer text should exist" do
    assert @player_answer.valid?
  end

  test "answer should link to a player" do
    @player_answer.player = nil
    assert_not @player_answer.valid?
  end

  test "answer should link to an answer" do
    @player_answer.answer = nil
    assert_not @player_answer.valid?
  end

  test "answer should link to a session" do
    @player_answer.trivia_session = nil
    assert_not @player_answer.valid?
  end
end
