class Admin::VideoArtistsController < AdminController
  def manager
    @video_artists = scoped_video_artist(params).page(params[:page]).per(500)
    @max_published_at = Movie.group(:channel).maximum(:published_at)
    @min_published_at = Movie.group(:channel).minimum(:published_at)
    @movie_count = VideoArtist.joins(:movies).group('video_artists.id').count
  end

  def sns
    @video_artists = VideoArtist.all.includes(:twitter_accounts, :instagram_accounts)
    gon.video_artists = @video_artists.as_json(methods: %i(twitter instagram channel_url))
  end

  def show
    @video_artist = VideoArtist.find(params[:id])
    @movies = @video_artist.movies.page(params[:page]).per(100)
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

  def update_latest_published_at
    if params[:channel].blank?
      VideoArtist.update_latest_published_at
    else
      VideoArtist.update_latest_published_at(params[:channel])
    end
    redirect_to manager_admin_video_artists_path
  end

  private

  def scoped_video_artist(params)
    return VideoArtist.all.order(:id) if params[:sort].blank?

    permitted_sort_params = params.require(:sort).permit(
      'movies.published_at', 'video_artists.id', 'video_artists.latest_published_at', 'movie_count'
    )

    return VideoArtist.all.order(:id) if permitted_sort_params.blank?
    return VideoArtist.ordr_by_movies_count(params[:sort][:movie_count]) if params[:sort][:movie_count].present?

    va = VideoArtist.joins(:movies).eager_load(:movies).order(
      permitted_sort_params.to_h.reject { |k, v|
        k == 'movie_count'
      }.map { |k, v| "#{k} #{v}" }.join(', ')
    )
  end

  def video_artist_params
    params.require(:video_artist).permit(
      :channel, :title, :editor_description, :description, :kana, :en
    )
  end
end
