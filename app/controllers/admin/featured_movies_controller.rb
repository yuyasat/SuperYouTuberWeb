class Admin::FeaturedMoviesController < AdminController
  def index
    @featured_movie = FeaturedMovie.new
    @featured_movies = FeaturedMovie.all.display_order.page(params[:page]).per(100)
  end

  def show
    @featured_movie = FeaturedMovie.find(params[:id])
  end

  def create
    featured_movie = FeaturedMovie.new(featured_movie_params)
    message = if featured_movie.save
                { success: "#{featured_movie.movie.key}をおすすめ動画に追加しました" }
              else
                { error: featured_movie.customized_error_full_messages }
              end

    redirect_to admin_featured_movies_path, flash: message
  end

  def update
    return destroy if params[:commit] == '削除'
    featured_movie = FeaturedMovie.find(params[:id])
    message = if featured_movie.update(featured_movie_params)
                { success: "#{featured_movie.movie.key}を更新しました" }
              else
                { error: featured_movie.customized_error_full_messages }
              end

    redirect_to admin_featured_movie_path(featured_movie), flash: message
  end

  private

  def destroy
    featured_movie = FeaturedMovie.find(params[:id])
    featured_movie.destroy
    redirect_to admin_featured_movies_path, flash: { success: "#{featured_movie.key}を削除しました" }
  rescue => e
    redirect_to admin_featured_movie_path(featured_movie), flash: {
      error: "#{featured_movie.key}の削除に失敗しました"
    }
  end


  def featured_movie_params
    params.require(:featured_movie).permit(
      %i(
        movie_id movie_key
        start_at(1i) start_at(2i) start_at(3i) start_at(4i) start_at(5i)
        end_at(1i) end_at(2i) end_at(3i) end_at(4i) end_at(5i)
      )
    )
  end
end
