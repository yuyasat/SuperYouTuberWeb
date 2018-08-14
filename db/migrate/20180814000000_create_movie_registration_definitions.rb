class CreateMovieRegistrationDefinitions < ActiveRecord::Migration[5.1]
  def change
    create_table :movie_registration_definitions do |t|
      t.references :video_artist, null: false
      t.references :category, null: false
      t.string :definition, null: false
      t.integer :match_type, null: false, default: 1

      t.timestamps
    end
  end
end
