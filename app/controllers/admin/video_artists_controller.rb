class Admin::VideoArtistsController < AdminController
  def manager
    @video_artists = VideoArtist.all.order(:id).page(params[:page]).per(500)
    @max_published_at = Movie.group(:channel).maximum(:published_at)
    @min_published_at = Movie.group(:channel).minimum(:published_at)
  end

  def sns
    @video_artists = VideoArtist.all.includes(:twitter_accounts, :instagram_accounts)
    gon.video_artists = @video_artists.as_json(methods: %i(twitter instagram channel_url))
  end

  def show
    @video_artist = VideoArtist.find(params[:id])
  end

  def update
    video_artist = VideoArtist.find_by(channel: video_artist_params[:channel])
    video_artist.assign_attributes(video_artist_params)

    message = if video_artist.save
                { success: "#{video_artist.channel}を更新しました" }
              else
                { error: video_artist.customized_error_full_messages }
              end

    redirect_to admin_video_artist_path(video_artist), flash: message
  end

  private

  def video_artist_params
    params.require(:video_artist).permit(
      :channel, :title, :editor_description, :description, :kana, :en
    )
  end
end
