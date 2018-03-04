class Category < ApplicationRecord
  has_many :movie_categories, dependent: :destroy
  has_many :movies, through: :movie_categories
  has_many :children, class_name: 'Category', foreign_key: :parent_id
  before_create :set_full_name, if: -> { full_name.blank? }

  validates :name, uniqueness: true

  scope :root, -> { where(parent_id: 0) }

  def root?
    parent_id == 0
  end

  def self.grouped_category_ids
    Category.root.eager_load({ children: :children }).map do |cat1|
      category_ids = [cat1.id] + cat1.children.pluck(:id) + cat1.children.flat_map do |cat2|
        cat2.children.pluck(:id)
      end
      [cat1, category_ids]
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
