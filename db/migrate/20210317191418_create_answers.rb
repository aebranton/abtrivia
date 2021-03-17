class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.text :answer
      t.boolean :correct, default: false
      t.timestamps
    end
  end
end
