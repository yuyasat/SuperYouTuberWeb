class Category < ApplicationRecord
  has_many :children, class_name: 'Category', foreign_key: :parent_id
  before_create :set_full_name, if: -> { full_name.blank? }

  validates :name, uniqueness: true

  scope :root, -> { where(parent_id: 0) }

  def root?
    parent_id == 0
  end

  def self.html_options
    [['親なし（第１にする）', 0]] + Category.root.includes(:children).flat_map do |cat1|
      [
        ["（第１）#{cat1.name}", cat1.id]
      ]+ cat1.children.map do |cat2|
        ["（第２）#{cat2.name}", cat2.id]
      end
    end
  end

  private

  def set_full_name
    self.full_name = name
  end
end
