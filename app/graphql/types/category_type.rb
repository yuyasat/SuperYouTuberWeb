module Types
  class CategoryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :display_order, Integer, null: false
    field :movies, [Types::MovieType], null: true do
      argument :num, Integer, required: false
      argument :page, Integer, required: false
    end

    def movies(num: 8, page: 1)
      object.related_categories_movies.page(page).per(8)
    end
  end
end
