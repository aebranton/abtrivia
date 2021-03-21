class AddQuestionIdToPlayerAnswer < ActiveRecord::Migration[6.1]
  def change
    add_column :player_answers, :question_id, :integer
  end
end
