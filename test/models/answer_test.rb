require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  def setup
    category = QuestionCategory.new(name: "Test")
    question = Question.new(question_category: category, question: "Willl these tests pass?")
    @answer = Answer.new(question: question, answer: "I bloody hope so!")
  end

  test "answer text should exist" do
    assert @answer.valid?
  end

  test "answer should not be too short" do
    assert_not @answer.answer.length < 1
  end

  test "should have a linked question" do
    assert !!@answer.question.question
  end
end
