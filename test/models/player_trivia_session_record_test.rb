require "test_helper"

class PlayerTriviaSessionRecordTest < ActiveSupport::TestCase
  def setup
    player = Player.new(display_name: "Alex Branton", email: "ae.branton9@gmail.com")
    trivia_session_state = TriviaSessionState.new(name: "Pending")
    trivia_session = TriviaSession.new(player: player, trivia_session_state: trivia_session_state, name: "Test Session")
    @pts_record = PlayerTriviaSessionRecord.new(player: player, trivia_session: trivia_session, victory: true)
  end

  test "player trivia session record should be valid" do
    assert @pts_record.valid?
  end

  test "player trivia session record should be linked to a session" do
    @pts_record.trivia_session = nil
    assert_not @pts_record.valid?
  end

  test "player trivia session record should be linked to a player" do
    @pts_record.player = nil
    assert_not @pts_record.valid?
  end
end
