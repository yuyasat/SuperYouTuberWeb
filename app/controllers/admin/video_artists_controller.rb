class Admin::VideoArtistsController < AdminController
  def manager
    @video_artists = scoped_video_artist(params).having_non_deleted_movies
                                                .includes(:memos).page(params[:page]).per(500)
    @max_published_at = Movie.group(:channel).maximum(:published_at)
    @min_published_at = Movie.group(:channel).minimum(:published_at)
    @movie_count = VideoArtist.joins(:movies).group('video_artists.id').count
  end

  def sns
    @video_artists = VideoArtist.all.includes(:twitter_accounts, :instagram_accounts)
    gon.video_artists = @video_artists.as_json(methods: %i(twitter instagram channel_url))
  end

  def show
    @video_artist = VideoArtist.includes(:instagram_accounts, :twitter_accounts).find(params[:id])
    @movies = @video_artist.movies.includes(
      :video_artist, :categories, :locations
    ).order(published_at: :desc).page(params[:page]).per(100)
    gon.movie_registration_definitions = @video_artist.most_relevant_movie_registration_definitions
  end

  def update
    form = Admin::VideoArtistUpdateForm.new(params)
    form.assign_attributes
    message = form.save

    redirect_to admin_video_artist_path(form.video_artist), flash: message
  end

  def update_latest_published_at
    if params[:channel].blank?
      VideoArtist.update_latest_published_at
    else
      VideoArtist.update_latest_published_at(params[:channel])
    end
    redirect_to manager_admin_video_artists_path(
      channel: params[:channel], sort: permitted_sort_params
    )
  end

  private

  def scoped_video_artist(params)
    va = VideoArtist
    va = va.order_by_music(params[:sort]['video_artists.music']) if params.dig(:sort, 'video_artists.music').present?

    case
    when params[:sort].blank? || permitted_sort_params.blank?
      va = va.all.order(:id)
    when params[:sort][:movie_count].present?
      va = va.order_by_movies_count(params[:sort][:movie_count])
    when params[:sort]['movies.published_at'].present?
      va = va.latest_published(params[:sort]['movies.published_at'])
    when params[:sort]['video_artists.unupdated_period'].present?
      va = va.order_by_ununpdated_period(params[:sort]['video_artists.unupdated_period'])
    else
      va = va.joins(:movies).eager_load(:movies).order(
        permitted_sort_params.to_h.reject { |k, v|
          k.in?(['movie_count', 'video_artists.music'])
        }.map { |k, v| "#{k} #{v}" }.join(', ')
      )
    end
  end

  def permitted_sort_params
    return params.permit if params[:sort].blank?
    params.require(:sort).permit(
      'video_artists.id', 'video_artists.latest_published_at', 'video_artists.unupdated_period',
      'movies.published_at', 'movie_count', 'video_artists.music'
    )
  end
end
