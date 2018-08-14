class AddAutoMovieRegistrationTypeToVideoArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :video_artists, :auto_movie_registration_type, :integer, null: false, default: 0
  end
end
