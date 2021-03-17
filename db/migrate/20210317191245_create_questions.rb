class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.integer :question_category_id
      t.text :question
      t.timestamps
    end
  end
end
