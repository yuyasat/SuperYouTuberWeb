class AdvertisementsDecorator < Draper::CollectionDecorator
  delegate :present?, to: :object

  def include_nend?(browser)
    memory_scope(browser).any? { |ad| ad.content.include?('nend') }
  end

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
