module Types
  class MovieType < Types::BaseObject
    field :id, ID, null: false
    field :url, String, null: false
    field :key, String, null: false
    field :status, String, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :published_at, String, null: false
    field :channel, String, null: false
    field :default_url, String, null: false
    field :mqdefault_url, String, null: false
  end
end
