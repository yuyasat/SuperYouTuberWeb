FactoryBot.define do
  factory :category do
    name 'YouTuberのこと'

    trait :root do
      parent_id 0
    end
  end
end
