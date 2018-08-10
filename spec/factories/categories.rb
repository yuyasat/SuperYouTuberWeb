FactoryBot.define do
  factory :category do
    id 1
    name 'Apple'

    initialize_with { Category.find_or_create_by(id: id, name: name) }

    trait :category_97 do
      id 97
      name 'YouTuberのこと'
      display_order 2
      after(:create) do |cat|
        cat.children = %w(
          98 記念
          254 ペット
          99 日常
        ).each_slice(2).map do |id, category_name|
          create(:category, id: id, name: category_name)
        end
      end
    end

    trait :category_431 do
      id 431
      name 'YouTuberがやってみた'
      display_order 3
      after(:create) do |cat|
        cat.children = %w(
          361 やってみた・行ってみた
          366 作ってみた
          364 実験してみた
        ).each_slice(2).map do |id, category_name|
          create(:category, id: id, name: category_name)
        end
      end
    end

    trait :with_two_movies do
      after(:build) do |cat|
        cat.movies = (1..2).map { |_| create(:movie, :without_api_calls) }
      end
    end

    trait :root do
      parent_id 0
    end

    factory :category_97__with_movies, traits: %i(category_97 with_two_movies)
    factory :category_431__with_movies, traits: %i(category_431 with_two_movies)
  end
end
