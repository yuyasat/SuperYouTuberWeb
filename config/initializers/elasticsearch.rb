config = {
  host: Settings.elasticsearch.host,
  transport_options: {
    request: { timeout: 10 }
  }
}

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
