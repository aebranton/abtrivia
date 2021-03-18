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

  test "display name should be at least 3 characters" do
    @player.display_name = "Ty"
    assert_not @player.valid?
  end

  test "display name should be at maximum 50 characters" do
    @player.display_name = "T" * 51
    assert_not @player.valid?
  end

  test "email must be present" do
    assert @player.valid?
  end

  test "email must not be too short" do
    @player.email = "ttt"
    assert_not @player.valid?
  end

  test "email must not be too long" do
    @player.email = "ttt" * 60 + "@aol.com"
    assert_not @player.valid?
  end

  test "email must not be duplicate (case insensitive)" do
    other = @player.dup
    other.email = @player.email.upcase
    @player.save
    assert_not other.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@eee.com R_TDD-DS@eee.hello.org user@example.com first.last@thing.au ppp+98.d@slammin.ti]
    valid_addresses.each do |add|
        @player.email = add
        assert @player.valid?, "#{add.inspect} should be valid"
    end
  end 
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user@example user.tim.com memail.org user#google.ca fooo@ee+ee.com]
    invalid_addresses.each do |add|
        @player.email = add
        assert_not @player.valid?, "#{add.inspect} should not be a valid address"
    end
  end  

end
