class AdvertisementsDecorator < Draper::CollectionDecorator
  def memory_scope(**scopes)
    object.select do |ad|
      scopes.all? { |k, v| v.is_a?(TrueClass) ? ad.send("#{k}?") : ad.send("#{k}?", v) }
    end
  end
end
