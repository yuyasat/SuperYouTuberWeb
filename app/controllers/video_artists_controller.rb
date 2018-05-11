class VideoArtistsController < ApplicationController
  def index
    @video_artists =
      if params[:kana].present?
        VideoArtist.search_kana(params[:kana]).order(:kana)
      else
        VideoArtist.joins(:movies).distinct.order('movies.published_at desc').includes(:movies)
      end
  end

  def show
    @video_artist = VideoArtist.find_by(channel: params[:id])
    @instagram_ogp = OpenGraph.new(@video_artist.instagram.url) if @video_artist.instagram.present?
  end
end
