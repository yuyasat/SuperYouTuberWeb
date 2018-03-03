class CreateMovieCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :movie_categories do |t|
      t.references :movie, null: false
      t.references :category, null: false

      t.timestamps null: false
    end
  end
end
