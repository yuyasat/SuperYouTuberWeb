class AddKanaAndEnToVideoArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :video_artists, :kana, :string
    add_column :video_artists, :en, :string
  end
end
