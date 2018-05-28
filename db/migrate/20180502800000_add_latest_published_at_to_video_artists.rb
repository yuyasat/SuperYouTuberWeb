class AddLatestPublishedAtToVideoArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :video_artists, :latest_published_at, :datetime
  end
end
