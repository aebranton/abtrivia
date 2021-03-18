class CreateQuestionCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :question_categories do |t|
      t.string :name
      t.timestamps
    end
  end
end
