class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :full_name, null: false
      t.references :parent, null: false, default: 0
      t.integer :display_order, null: false, default: 0

      t.timestamps null: false
    end
  end
end
