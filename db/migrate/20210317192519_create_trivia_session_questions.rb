class CreateTriviaSessionQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :trivia_session_questions do |t|
      t.integer :trivia_session_id, :question_id, :question_index
      t.timestamps
    end
  end
end
