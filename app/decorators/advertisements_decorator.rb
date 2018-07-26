class AdvertisementsDecorator < Draper::CollectionDecorator
  def memory_scope(browser, index = nil, **scopes)
    object.select do |ad|
      scopes.merge(sp: !!browser.mobile?, pc: !browser.mobile?).select { |_, v| v }.all? do |k, v|
        if k == :category
          ad.category?(v) || ad.category? && index.in?(ad.orders)
        else
          v.is_a?(TrueClass) ? ad.send("#{k}?") : ad.send("#{k}?", v)
        end
      end
    end
  end
end
