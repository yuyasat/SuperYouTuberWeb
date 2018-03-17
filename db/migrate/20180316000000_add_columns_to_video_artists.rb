class AddColumnsToVideoArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :video_artists, :custom_url, :string
    add_column :video_artists, :editor_description, :text
    add_column :video_artists, :description, :text
    add_column :video_artists, :default_thumbnail_url, :string
    add_column :video_artists, :medium_thumbnail_url, :string
    add_column :video_artists, :high_thumbnail_url, :string
  end
end
