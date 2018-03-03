class Admin::CategoriesController < ApplicationController
  def index
    @category = Category.new
    @root_categories = Category.root.includes(:children)
  end

  def show
  end

  def create
    category = Category.new(category_params)
    message = if category.save
                { success: "#{category.name}を追加しました" }
              else
                { error: category.customized_error_full_messages }
              end
    redirect_to admin_categories_path, flash: message
  end

  private

  def category_params
    params.require(:category).permit(:name, :full_name, :parent_id)
  end
end
