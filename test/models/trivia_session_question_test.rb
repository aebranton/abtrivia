require "test_helper"

class TriviaSessionQuestionTest < ActiveSupport::TestCase
  def setup
    category = QuestionCategory.new(name: "Test")
    @question = Question.new(question_category: category, question: "Willl these tests pass?")
    answer = Answer.new(question: @question, answer: "I bloody hope so!")
    player = Player.new(display_name: "Alex Branton", email: "ae.branton9@gmail.com")
    trivia_session_state = TriviaSessionState.new(name: "Pending")
    @trivia_session = TriviaSession.new(player: player, trivia_session_state: trivia_session_state, name: "Test Session")
    @ts_question = TriviaSessionQuestion.new(trivia_session: @trivia_session, question: @question, question_index: 1)
  end

  test "trivia session question should be valid" do
    assert @ts_question.valid?
  end

  test "trivia session question should have a linked question" do
    @ts_question.question = nil
    assert_not @ts_question.valid?
  end

  test "trivia session question should have a linked session" do
    @ts_question.trivia_session = nil
    assert_not @ts_question.valid?
  end

  test "trivia session question should have a question index" do
    @ts_question.trivia_session = nil
    assert_not @ts_question.valid?
  end

  test "trivia session question should have a unique question index" do
    other = TriviaSessionQuestion.new(trivia_session: @trivia_session, question: @question, question_index: 1)
    @ts_question.save
    other.save
    assert_not other.valid?
  end
end
