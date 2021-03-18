class CreatePlayerAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :player_answers do |t|
      t.integer :player_id, :trivia_session_id, :answer_id      
      t.timestamps
    end
  end
end
