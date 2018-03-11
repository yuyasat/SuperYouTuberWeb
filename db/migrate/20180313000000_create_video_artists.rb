class CreateVideoArtists < ActiveRecord::Migration[5.0]
  def change
    create_table :video_artists do |t|
      t.string :channel, null: false
      t.string :title

      t.timestamps null: false
    end
  end
end
