class CreateTriviaSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :trivia_sessions do |t|
      t.integer :player_id, :min_players, :trivia_session_state
      t.string :name
      t.timestamps
    end
  end
end
