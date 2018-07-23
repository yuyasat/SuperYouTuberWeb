class Advertisement < ApplicationRecord
  enum location: {
    top: 1,
    infeed: 2,
    middle: 3,
    bottom: 4,
  }
  enum device: {
    pc: 1,
    sp: 2,
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
end
