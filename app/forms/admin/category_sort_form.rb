class Admin::CategorySortForm
  include ActiveModel::Model

  attr_accessor :params, :categories

  def initialize(params)
    @params = params
  end

  def assign_attributes
    @categories = category_sort_params.map do |category_sort_param|
      category = Category.find(category_sort_param[:id])
      category.display_order = category_sort_param[:display_order]
      category
    end
  end

  def save!
    @categories.each(&:save!)
  end

  private

  def category_sort_params
    @params.require(:category).map { |c| c.permit(:id, :display_order) }
  end
end
