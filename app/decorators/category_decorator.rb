class CategoryDecorator < Draper::Decorator
  delegate_all

  def path
    "/categories/#{ancestor_categories.join('/')}"
  end
end
