class Admin::MovieUpdateForm
  attr_accessor :params, :movie

  def initialize(params)
    @params = params
    @movie = Movie.find(params[:id])
  end

  def assign_attributes
    movie.assign_attributes(movie_params.except(:movie_categories_attributes, :locations_attributes))
    @movie_categories = movie_category_params.values.select do |mcp|
      mcp[:category_id].present?
    end.map { |p| MovieCategory.new(p) }
    @locations = locations_params&.values&.map { |p| Location.new(p) } || []
  end

  def save
    Movie.transaction do
      if movie.category_changed?(@movie_categories)
        movie.movie_categories.delete_all
        @movie_categories.each { |category| movie.movie_categories << category }
        @movie.locations.destroy_all unless @movie.categories.any?(&:mappable?)
      end
      if @locations.present? && movie.locations_changed?(@locations)
        movie.locations.destroy_all
        @locations.each { |location| movie.locations << location }
      end

      if movie.save
        { success: "#{movie.key}を更新しました" }
      else
        { error: movie.customized_error_full_messages }
      end
    end
  end

  private

  def movie_params
    row_params = params.require(:movie).permit(
      :url, :key, :status, :title, :published_at, :channel, :description, :registered_type,
      movie_categories_attributes: %i(category_id),
      locations_attributes: %i(latlong latitude longitude),
    )
    row_params[:locations_attributes]&.reject! { |k, v| v.values.any?(&:blank?) }
    row_params
  end

  def movie_category_params
    movie_params[:movie_categories_attributes]
  end

  def locations_params
    movie_params[:locations_attributes]
  end
end
