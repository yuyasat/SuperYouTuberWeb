class Admin::VideoArtistsController < ApplicationController
  def index
    @video_artists = VideoArtist.all.includes(:twitter_accounts, :instagram_accounts)
    gon.video_artists = @video_artists.as_json(methods: %i(twitter instagram channel_url))
  end
end
