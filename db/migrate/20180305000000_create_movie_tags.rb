class CreateMovieTags < ActiveRecord::Migration[5.0]
  def change
    create_table :movie_tags do |t|
      t.references :movie, null: false
      t.references :tag, null: false

      t.timestamps null: false
    end
  end
end
