class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(num: 10)
    @root_category = Category.root.where(id: @category_movies.keys.map(&:id)).sort_by_display_order
  end

  def show
    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id])
    raise ActiveRecord::RecordNotFound if @category.blank?

    # FIXME: みのがてきとうに書いたので、きれいにしていただいてもよろしいでしょうか？ m(_ _)m
    @breadcrumb = [{label: 'カテゴリ一覧', link: '/categories'}]
    @breadcrumb.concat(@category.ancestor_categories(only_id: false).map{|o|
      {
        label: o.name,
        link: o.id == @category.id ? nil : o.decorate.path
      }
    })

    @movies = @category.related_categories_movies.page(params[:page])
  end
end
