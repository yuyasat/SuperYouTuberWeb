class Advertisement < ApplicationRecord
  enum location: {
    top: 1,
    infeed: 2,
    middle: 3,
    bottom: 4,
  }
  enum device: {
    only_pc: 1,
    only_sp: 2,
    both: 3,
  }

  t = arel_table
  scope :active, ->(now = Time.current) {
    where(t[:start_at].lteq(now)).where(t[:end_at].eq(nil).or(t[:end_at].gt(now)))
  }
  scope :latest_published, -> { where("LOWER(target ->> 'type') = 'latest'") }
  scope :youtuber, -> { where("LOWER(target ->> 'type') = 'youtuber'") }
  scope :category, ->(category_or_id = nil) {
    cat_id = category_or_id.is_a?(Category) ? category_or_id.id : category_or_id
    cat_ad = where("LOWER(target ->> 'type') = 'category'")
    category_or_id.blank? ? cat_ad : cat_ad.where("target ->> 'id' = '#{cat_id}'")
  }
  scope :music, ->(music_url = nil) {
    music_url = music_url.gsub('/music/', '')
    music_ad = where("LOWER(target ->> 'type') = 'music'")
    music_url.blank? ? music_ad : music_ad.where("target ->> 'url' = '#{music_url}'")
  }

  validates :start_at, presence: true

  def pc?
    both? || only_pc?
  end

  def sp?
    both? || only_sp?
  end

  def latest_published?
    target_type == 'latest'
  end

  def youtuber?
    target_type == 'youtuber'
  end

  def category?(category_or_id = nil)
    cat_id = category_or_id.is_a?(Category) ? category_or_id.id : category_or_id
    if category_or_id.blank?
      target_type == 'category'
    else
      target_type == 'category' && target['id'] == cat_id
    end
  end

  def music?(music_url = nil)
    music_url = music_url.gsub('/music/', '')
    if music_url.blank?
      target_type == 'music'
    else
      target_type == 'music' && target['id'] == music_url
    end
  end

  def orders
    target['orders'].to_a
  end

  def image_url
    content.match(/<img.*?src\s*=\s*[\"|\'](.*?)[\"|\'].*?>/)&.captures&.first
  end

  private

  def target_type
    target['type']&.downcase
  end
end
