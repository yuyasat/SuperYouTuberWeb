class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :url, null: false
      t.string :key, null: false
      t.integer :status, null: false, default: 1
      t.string :title, null: true
      t.text :description, null: true

      t.timestamps null: false
    end
  end
end
