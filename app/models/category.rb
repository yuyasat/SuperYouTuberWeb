class Category < ApplicationRecord
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_id

  has_many :movie_categories, dependent: :destroy
  has_many :movies, through: :movie_categories
  has_many :children, -> { order(:display_order, :created_at) }, class_name: 'Category', foreign_key: :parent_id
  before_create :set_full_name, if: -> { full_name.blank? }
  before_create :set_display_order

  scope :root, -> { where(parent_id: 0) }
  scope :sort_by_display_order, -> { order(:display_order, :created_at) }

  def root?
    parent_id == 0
  end

  def secondary?
    parent_category.root?
  end

  def tertiary?
    parent_category && parent_category.parent_category.root?
  end

  def related_categories_movies
    Movie.where(
      id: MovieCategory.where(category: all_children_categories).select('movie_categories.movie_id')
    ).order(published_at: :desc)
  end

  def ancestor_categories(category = self, result = [], only_id: true)
    return result + [only_id ? category.id : category] if category.root?
    ancestor_categories(category.parent_category, result, only_id: only_id) + [only_id ? category.id : category]
  end

  def all_children_categories(include_self: true, only_id: true)
    [].tap do |a|
      a << (only_id ? self.id : self) if include_self
      children.eager_load(:children).each do |cat2|
        a << (only_id ? cat2.id : cat2)
        cat2.children.each do |cat3|
          a << (only_id ? cat3.id : cat3)
        end
      end
    end
  end

  def self.grouped_category_ids
    Category.root.sort_by_display_order.eager_load(children: :children).map do |cat1|
      [cat1, cat1.all_children_categories]
    end.to_h
  end

  def self.html_options(with_root: true)
    root_option = with_root ? [['親なし（第１にする）', 0]] : []
    root_option + [].tap do |a|
      Category.root.sort_by_display_order.eager_load(children: :children).each do |cat1|
        a << [cat1.name, cat1.id]
        cat1.children.each do |cat2|
          a << ["　#{cat2.name}", cat2.id]
          cat2.children.each do |cat3|
            a << ["　　#{cat3.name}", cat3.id]
          end
        end
      end
    end
  end

  private

  def set_full_name
    self.full_name = name
  end

  def set_display_order
    if root?
      self.display_order = self.class.root.sort_by_display_order.last.display_order + 1
      return
    end
    return if parent_category.children.all? { |cat| cat.display_order.zero? }
    self.display_order = parent_category.children.last.display_order + 1
  end
end
