class Category < ApplicationRecord
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_id

  has_one :special_category, dependent: :destroy
  has_many :movie_categories, dependent: :destroy
  has_many :movies, through: :movie_categories
  has_many :children, -> { order(:display_order, :created_at) }, class_name: 'Category', foreign_key: :parent_id
  has_many :movie_registration_definitions

  before_create :set_full_name, if: -> { full_name.blank? }
  before_create :set_display_order
  after_save :delete_special_category, if: -> { special_category.present? && !mappable? && !music? }

  accepts_nested_attributes_for :special_category, reject_if: :all_blank, allow_destroy: true

  scope :root, -> { where(parent_id: 0) }
  scope :secondary, -> { where(parent_id: root.select(:id)) }
  scope :tertiary, -> { where.not(id: root.select(:id) + secondary.select(:id)) }
  scope :sort_by_display_order, -> { order(:display_order, :created_at) }
  scope :not_special, -> { where.not(id: SpecialCategory.select('category_id').distinct) }
  scope :have_movies, -> {
    where(id: MovieCategory.select('distinct category_id'))
  }
  scope :no_children, -> { where.not(id: Category.select(:parent_id).distinct) }
  scope :mappable, -> {
    where(id: Category.find_by(name: 'マップ').all_children_categories)
  }
  scope :musicable, -> { where(id: Category.music.all_children_categories) }

  def root?
    parent_id == 0
  end

  def secondary?
    parent_category.root?
  end

  def tertiary?
    parent_category && parent_category.parent_category.root?
  end

  def destroyable?
    movies.blank? && children.blank?
  end

  def special_root?
    name.in?(%|マップ ミュージックPV|)
  end

  def special_secondary?
    name.in?(%|ジャンルからさがす|)
  end

  def mappable?
    Category.find_by(name: 'マップ').all_children_categories.include?(id)
  end

  def music?
    ancestor_categories(only_id: false).first.name == 'ミュージックPV'
  end

  def main_video_artist
    channel = movies.group('channel').order('count_all DESC').count.keys.first
    VideoArtist.find_by(channel: channel)
  end

  def related_categories_movies
    Movie.where(
      id: MovieCategory.where(category: all_children_categories).select('movie_categories.movie_id')
    ).active.order(published_at: :desc)
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

  def grouped_category_ids
    children.sort_by_display_order.map do |cat|
      [cat, cat.all_children_categories]
    end.to_h
  end

  def self.music
    find_by(name: 'ミュージックPV')
  end

  def self.grouped_category_ids
    Category.root.sort_by_display_order.eager_load(children: :children).map do |cat1|
      [cat1, cat1.all_children_categories]
    end.to_h
  end

  def self.html_options(with_root: true, short: false)
    root_option = with_root ? [['親なし（第１にする）', 0]] : []
    (root_option + [].tap do |a|
      Category.root.sort_by_display_order.eager_load(children: :children).each do |cat1|
        a << [cat1.name, cat1.id]
        cat1.children.sort_by { |c| [c.display_order, c.created_at] }.each do |cat2|
          a << ["　#{cat2.name}", cat2.id]
          cat2.children.sort_by { |c| [c.display_order, c.created_at] }.each do |cat3|
            a << ["　　#{cat3.name}", cat3.id]
          end
        end
      end
    end).map do |c|
      short && c[0].length > 15 ? ["#{c[0][0..15]}...", c[1]] : [c[0], c[1]]
    end
  end

  def self.movie_count_each_category
    tertiary_movie_cnt = tertiary.includes(:movies).map { |cat3| [cat3, cat3.movies.size] }.to_h
    secondary_movie_cnt = secondary.includes(:movies).map { |cat2| [cat2, cat2.movies.size] }.to_h
    root_movie_cnt = root.includes(:movies).map { |cat1| [cat1, cat1.movies.size] }.to_h

    secondary_children = secondary.includes(:children).map { |cat2| [cat2, cat2.children] }.to_h
    root_children = root.includes(:children).map { |cat1| [cat1, cat1.children] }.to_h

    root.sort_by_display_order.map do |cat1|
      tertiary_cat_cnt = secondary_children.values_at(*root_children[cat1]).flatten.size
      secondary_cat_cnt = root_children[cat1].presence&.size || 1
      secondary_cat_with_tertiary_cnt =
        secondary_children.values_at(*root_children[cat1]).reject { |cats| cats.blank? }.size
      cat1_height = tertiary_cat_cnt + secondary_cat_cnt - secondary_cat_with_tertiary_cnt

      cat1_movie_count =
        tertiary_movie_cnt.values_at(*secondary_children.values_at(*root_children[cat1]).flatten).sum +
        secondary_movie_cnt.values_at(*root_children[cat1]).sum + root_movie_cnt[cat1]

      [
        cat1,
        {
          height: cat1_height,
          movie_count: cat1_movie_count,
          self_movie_count: root_movie_cnt[cat1],
          children: root_children[cat1].map do |cat2|
            cat2_height = secondary_children[cat2].presence&.size || 1
            cat2_movie_count =
              tertiary_movie_cnt.values_at(*secondary_children[cat2]).sum + secondary_movie_cnt[cat2]

            [
              cat2,
              {
                height: cat2_height,
                movie_count: cat2_movie_count,
                self_movie_count: secondary_movie_cnt[cat2],
                children: secondary_children[cat2].map do |cat3|
                  [cat3, { movie_count: tertiary_movie_cnt[cat3] }]
                end.to_h,
              }
            ]
          end.to_h,
        }
      ]
    end.to_h
  end

  private

  def set_full_name
    self.full_name = name
  end

  def set_display_order
    if root?
      return unless self.class.root.exists?
      self.display_order = self.class.root.sort_by_display_order.last.display_order + 1
      return
    end
    return if parent_category.children.all? { |cat| cat.display_order.zero? }
    self.display_order = parent_category.children.last.display_order + 1
  end

  def delete_special_category
    special_category.destroy
  end
end
