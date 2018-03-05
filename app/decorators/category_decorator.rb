class CategoryDecorator < Draper::Decorator
  delegate_all

  def children_path
    "/categories/#{ancestor_category_ids.join('/')}"
  end
end
