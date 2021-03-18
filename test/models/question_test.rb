require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  def setup
    category = QuestionCategory.new(name: "Test")
    @question = Question.new(question_category: category, question: "Willl these tests pass?")
  end

  test "question text should exist" do
    assert @question.valid?
  end

  test "question should not be too short" do
    @question.question = "only some"
    assert_not @question.valid?
  end

  test "question should not be too long" do
    @question.question = "only some" * 50
    assert_not @question.valid?
  end

  test "question should have a linked category" do
    assert !!@question.question_category.name
  end
end
