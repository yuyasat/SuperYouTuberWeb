class Category < ApplicationRecord
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_id

  has_many :movie_categories, dependent: :destroy
  has_many :movies, through: :movie_categories
  has_many :children, class_name: 'Category', foreign_key: :parent_id
  before_create :set_full_name, if: -> { full_name.blank? }

  validates :name, uniqueness: true

  scope :root, -> { where(parent_id: 0) }

  def root?
    parent_id == 0
  end

  def secondary?
    parent_category.root?
  end

  def tertiary?
    parent_category && parent_category.parent_category.root?
  end

  def belonging_movies
    Movie.where(
      id: MovieCategory.where(category: children_category_ids).select('movie_categories.movie_id')
    )
  end

  def ancestor_categories(category = self, result = [], only_id: true)
    return result + [only_id ? category.id : category] if category.root?
    ancestor_categories(category.parent_category, result, only_id: only_id) + [only_id ? category.id : category]
  end

  def children_category_ids(include_self: true)
    (include_self ? [id] : []) +
      children.pluck(:id) +
      children.eager_load(:children).flat_map { |cat2| cat2.children.pluck(:id) }
  end

  def self.grouped_category_ids
    Category.root.eager_load({ children: :children }).map do |cat1|
      [cat1, cat1.children_category_ids]
    end.to_h
  end

  def self.html_options(with_root: true)
    root_option = with_root ? [['親なし（第１にする）', 0]] : []
    root_option + Category.root.includes(:children).flat_map do |cat1|
      [[cat1.name, cat1.id]]+ cat1.children.map { |cat2| ["　　#{cat2.name}", cat2.id] }
    end
  end

  private

  def set_full_name
    self.full_name = name
  end
end
