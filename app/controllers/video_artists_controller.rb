class VideoArtistsController < ApplicationController
  def index
    @video_artists =
      if params[:kana].present? || params[:en].present?
        VideoArtist.start_with(kana: params[:kana], en: params[:en])
      else
        VideoArtist.joins(:movies).distinct.order('movies.published_at desc').includes(:movies)
      end
    @alphabets_having_video_artists = VideoArtist.start_alphabet
  end

  def show
    @video_artist = VideoArtist.find_by(channel: params[:id])
    @instagram_ogp = OpenGraph.new(@video_artist.instagram.url) if @video_artist.instagram.present?
  end
end
