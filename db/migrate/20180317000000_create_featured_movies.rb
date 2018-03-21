class CreateFeaturedMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :featured_movies do |t|
      t.references :movie, null: false
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end
