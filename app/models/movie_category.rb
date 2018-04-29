class MovieCategory < ApplicationRecord
  belongs_to :movie
  belongs_to :category

  scope :with_category_like, ->(catgory_name) {
    where(category: Category.where('name like ?', "%#{catgory_name}%"))
  }
end
