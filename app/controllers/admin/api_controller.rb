class Admin::ApiController < AdminController
  def movie_info
    return render json: { error: 'Invalid Movie Key' } unless params[:movie_key].length == 11

    render json: JSON.parse(YoutubeApi.get_movie_info(params))
  end

  def movie_exists
    render json: { exists: Movie.exists?(key: params[:movie_key]) }
  end

  def video_artist
    video_artist = VideoArtist.find(video_artist_params[:id])
    form = Admin::SnsAccountForm.new(params)
    form.assign_attributes
    form.save!
    render json: { twitter: video_artist.twitter, instagram: video_artist.instagram }
  end

  def movies
    movies_json = searched_movies.as_json(
                    methods: %i(default_url channel_url status_i18n registered_type_i18n),
                    include: {
                      video_artist: { only: %i(id title) },
                      categories: { only: %i(id name) },
                      locations: { methods: %i(latitude longitude latlong) },
                    }
                  )

    render json: { movies: movies_json, total_pages: searched_movies.total_pages }
  end

  def children_categories
    cat = Category.find(params[:category_id])
    render json: { categories: cat.children.sort_by_display_order }
  end

  private

  def searched_movies
    order_cond = params[:sort_by].present? ? { params[:sort_by] => params[:sort_sc] } : { id: :desc }
    movies = Movie.order(order_cond)
    movies = movies.where(key: params[:title_search]) if params[:title_search].present?
    if params[:category_search].present?
      movies = movies.where(id: MovieCategory.with_category_like("%#{params[:category_search]}%").select('movie_id'))
    end
    if params[:category_id].present?
      movies = movies.of_category(Category.find(params[:category_id]))
    end
    movies.includes(:video_artist, :categories, :locations).page(params[:page]).per(100)
  end

  def video_artist_params
    params.require(:video_artist).permit(:id, :channel, :title, :kana, :en)
  end
end
