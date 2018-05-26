class VideoArtistDecorator < Draper::Decorator
  delegate_all

  def categories_str
    categories.map(&:name).join(', ')
  end
end
