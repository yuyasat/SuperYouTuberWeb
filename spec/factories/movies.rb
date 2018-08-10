FactoryBot.define do
  factory :movie do
    sequence(:key) { |i| sprintf("%011d",i) }
    url { "https://www.youtube.com/watch?v=#{key}" }
    sequence(:title) { |i| "動画タイトル#{sprintf("%04d", i)}" }
    sequence(:channel) { |i| "UCZf__ehlCEBPop-_#{sprintf("%07d", i)}" }

    published_at Time.current - 1.day

    initialize_with { Movie.find_or_create_by(key: key) }

    trait :active do
      status "active"
    end

    trait :without_api_calls do
      after(:build) do |movie|
        allow(movie).to receive(:create_video_artist).and_return(true)
        allow_any_instance_of(
          Elasticsearch::Model::Indexing::InstanceMethods
        ).to receive(:index_document).and_return(true)
      end
    end
  end
end
