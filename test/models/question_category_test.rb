require "test_helper"

class QuestionCategoryTest < ActiveSupport::TestCase
  def setup
    @category = QuestionCategory.new(name: "Test")
  end

  test "category should contain a name" do
    assert @category.valid?
  end

  test "category name should not be too short" do
    @category.name = "tt"
    assert_not @category.valid?
  end

  test "category name should not be too long" do
    @category.name = "t" * 21
    assert_not @category.valid?
  end

end
