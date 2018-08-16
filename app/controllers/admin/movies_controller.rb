class Admin::MoviesController < AdminController

  def index
    @movie = Movie.new
    set_gon_attributes
  end

  def auto_registered
    @movies = Movie.registered_type_auto.order(created_at: :desc).page(params[:page]).per(100)
  end

  def deleted
    @movies = Movie.deleted.order(updated_at: :desc).page(params[:page]).per(100)
  end

  def show
    @movie = Movie.find(params[:id])
    set_gon_attributes
  end

  def create
    movie = Movie.new(movie_params)
    message = if movie.save
                { success: "#{movie.key}を追加しました" }
              else
                { error: movie.customized_error_full_messages }
              end
    redirect_to admin_movies_path(
      category_id: movie.categories&.first&.id, category_id2: movie.categories[1]&.id
    ), flash: message
  end

  def update
    return destroy if params[:commit] == '削除'
    form = Admin::MovieUpdateForm.new(params)
    form.assign_attributes
    message = form.save

    redirect_to admin_movie_path(form.movie), flash: message
  end

  private

  def destroy
    movie = Movie.find(params[:id])
    movie.destroy
    redirect_to admin_movies_path, flash: { success: "#{movie.key}を削除しました" }
  rescue => e
    redirect_to admin_movie_path(movie), flash: { error: "#{movie.key}の削除に失敗しました" }
  end

  def movie_params
    row_params = params.require(:movie).permit(
      :url, :key, :status, :title, :published_at, :channel, :description,
      movie_categories_attributes: %i(category_id),
      locations_attributes: %i(latlong latitude longitude),
    )
    row_params[:locations_attributes]&.reject! { |k, v| v.values.any?(&:blank?) }
    row_params
  end

  def set_gon_attributes
    gon.movie = @movie
    gon.movie_categories = @movie.categories
    gon.default_category = params[:category_id]
    gon.map_category_ids = Category.find_by(name: 'マップ').all_children_categories
    gon.movie_locations = @movie.locations.as_json(methods: %i(latitude longitude latlong))
                                .map.with_index { |json, i| json.merge(index: i) }
    gon.root_categories = Category.root.sort_by_display_order
  end
end
