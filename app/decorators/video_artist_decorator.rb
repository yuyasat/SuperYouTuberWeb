class VideoArtistDecorator < Draper::Decorator
  delegate_all

  def categories_str
    categories.map(&:name).join(', ')
  end

  def title_with_music_artist(target_category)
    return title if target_category.blank? || categories.count == 1
    "#{title}（#{target_category.name}）"
  end
end
