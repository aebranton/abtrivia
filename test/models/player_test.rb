require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def setup
    @player = Player.new(display_name: "Alex Branton", email: "ae.branton9@gmail.com")
  end
  
  test "display name should be valid" do
    assert @player.valid?
  end

  test "display name should be present" do
    @player.display_name = ""
    assert_not @player.valid?
  end
end
