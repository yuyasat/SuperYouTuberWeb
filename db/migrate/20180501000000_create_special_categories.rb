class CreateSpecialCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :special_categories do |t|
      t.references :category, null: false
      t.string :url, null: false

      t.timestamps null: false
    end
  end
end
