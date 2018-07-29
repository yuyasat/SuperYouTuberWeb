class Admin::CategoriesController < AdminController
  before_action :set_instance_variables_for_index, only: %i(index index_sort index_dashboard)
  before_action :set_instance_variables_for_show, only: %i(show show_sort)

  def index
  end

  def index_sort
  end

  def index_dashboard
    @dashboard = Category.movie_count_each_category
  end


  def show
    @movies =
      @category.movies.order(created_at: :desc).includes(:categories).page(params[:page]).per(100)
  end

  def show_sort
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
    return destroy if params[:commit] == '削除'
    category = Category.find(params[:id])
    category.assign_attributes(category_params)
    message = if category.changed? || category.special_category&.changed?
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

  def destroy
    category = Category.find(params[:id])
    unless category.destroyable?
      redirect_to admin_category_path(category), flash: { error: "#{category.name}は削除できません。" }
      return
    end
    category.destroy
    redirect_to admin_categories_path, flash: { success: "#{category.name}を削除しました" }
  rescue => e
    redirect_to admin_category_path(category), flash: { error: "#{category.name}の削除に失敗しました" }
  end

  def category_params
    params.require(:category).permit(
      :name, :full_name, :parent_id, :description,
      special_category_attributes: %i(url),
    )
  end

  def category_sort_params
    params.require(:category).map { |c| c.permit(:id, :display_order) }
  end

  def set_instance_variables_for_index
    @category = Category.new
    @root_categories = Category.root.sort_by_display_order.eager_load(children: :children)
    gon.children_categories = @root_categories
    gon.music_category_ids = Category.music.all_children_categories
  end

  def set_instance_variables_for_show
    @category = Category.find(params[:id])
    gon.children_categories = @category.children
    gon.parent_category_id = @category.parent_id
    gon.music_category_ids = Category.music.all_children_categories
  end

  def sort_category!
    form = Admin::CategorySortForm.new(params)
    form.assign_attributes
    form.save!
  end
end
