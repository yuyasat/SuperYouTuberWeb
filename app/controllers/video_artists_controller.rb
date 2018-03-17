class VideoArtistsController < ApplicationController
  def show
    @video_artist = VideoArtist.find_by(channel: params[:id])
    @instagram_ogp = OpenGraph.new(@video_artist.instagram.url)
  end
end
