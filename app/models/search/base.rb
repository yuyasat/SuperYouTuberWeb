class Search::Base
  DEFAULT_PER = 24

  def execute(options = {})
    self.class.execute(model, query, options)
  end

  def self.execute(model, query, options = {})
    page = options[:page] || 1
    per  = options[:per] || DEFAULT_PER

    records = model.__elasticsearch__.search(query).page(page).per(per).records
    kaminari_options = {
      limit: records.limit_value,
      offset: records.offset_value,
      total_count: records.total_count,
    }
    records = yield(records) if block_given?

    Kaminari.paginate_array(records.to_a, kaminari_options)
  end

  private

  def query
    raise 'Please implement!'
  end

  def model
    raise 'Please implement!'
  end
end
