class Admin::CategoriesController < ApplicationController
  before_action :set_instance_variables_for_index, only: %i(index index_sort)

  def index
  end

  def index_sort
  end


  def show
    @category = Category.find(params[:id])
    gon.children_categories = @category.children
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

  def update
    category = Category.find(params[:id])
    category.assign_attributes(category_params)
    message = if category.changed?
                if category.save
                  { success: "#{category.name}を更新しました" }
                else
                  { error: category.customized_error_full_messages }
                end
              else
                { error: '変更がありません' }
              end

    redirect_to admin_category_path(category), flash: message
  end

  def sort
    sort_category!
    redirect_to admin_category_path(Category.find(params[:id]))
  end

  def sort_root_category
    sort_category!
    redirect_to sort_admin_categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :full_name, :parent_id)
  end

  def category_sort_params
    params.require(:category).map { |c| c.permit(:id, :display_order) }
  end

  def set_instance_variables_for_index
    @category = Category.new
    @root_categories = Category.root.includes(:children)
    gon.children_categories = @root_categories
  end

  def sort_category!
    form = Admin::CategorySortForm.new(params)
    form.assign_attributes
    form.save!
  end
end
