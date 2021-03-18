class CreateTriviaSessionStates < ActiveRecord::Migration[6.1]
  def change
    create_table :trivia_session_states do |t|
      t.string :name
      t.timestamps
    end
  end
end
