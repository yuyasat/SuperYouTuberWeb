module Types
  class QueryType < Types::BaseObject
    field :category, CategoryType, null: true do
      argument :id, ID, required: true
    end

    field :category_movies, [CategoryType], null: true do
      argument :ids, [Integer], required: false
    end

    def category(id:)
      Category.find(id)
    end

    def category_movies(ids:)
      (ids.blank? ? Category.root : Category.where(id: ids)).sort_by_display_order
    end
  end
end
