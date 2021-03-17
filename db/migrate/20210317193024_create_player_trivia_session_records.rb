class CreatePlayerTriviaSessionRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :player_trivia_session_records do |t|
      t.integer :player_id, :trivia_session_id
      t.boolean :victory, default: false
      t.timestamps
    end
  end
end
