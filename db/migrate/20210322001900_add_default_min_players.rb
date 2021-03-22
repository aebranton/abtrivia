class AddDefaultMinPlayers < ActiveRecord::Migration[6.1]
  def change
    change_column :trivia_sessions, :min_players, :integer, :default => 2
  end
end
