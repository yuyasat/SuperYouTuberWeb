require 'rails_helper'

RSpec.describe 'categoryMovies query', type: :request do
  let(:category_431) { create(:category_431__with_movies) }
  let(:category_97) { create(:category_97__with_movies) }

  before do
    category_97
    category_431
    post internal_graphql_path, params: { query: query }
  end

  let(:query) do
    <<~QUERY
      {
        categoryMovies(ids: #{ids}) {
          id
          name
          movies(num: 2) {
            id
            title
            publishedAt
          }
        }
      }
    QUERY
  end

  context 'when ids do not exist' do
    let(:ids) { 'null' }

    it 'response body is category data' do
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:data][:categoryMovies].count).to eq 2

      expect(json[:data][:categoryMovies][0][:name]).to eq 'YouTuberのこと'
      expect(json[:data][:categoryMovies][0][:movies].count).to eq 2

      expect(json[:data][:categoryMovies][1][:name]).to eq 'YouTuberがやってみた'
      expect(json[:data][:categoryMovies][1][:movies].count).to eq 2
    end
  end

  context 'when ids exist' do
    let(:ids) { [431] }

    it 'response body is category data' do
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:data][:categoryMovies].count).to eq 1

      expect(json[:data][:categoryMovies][0][:name]).to eq 'YouTuberがやってみた'
      expect(json[:data][:categoryMovies][0][:movies].count).to eq 2
    end
  end
end
