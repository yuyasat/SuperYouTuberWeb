class VideoArtistsController < ApplicationController
  def index
    @video_artists = VideoArtist.joins(:movies)
                                .order('movies.published_at desc')
                                .includes(:movies, :instagram_accounts, :twitter_accounts)
  end

  def show
    @video_artist = VideoArtist.find_by(channel: params[:id])
    @instagram_ogp = OpenGraph.new(@video_artist.instagram.url) if @video_artist.instagram.present?
  end
end
