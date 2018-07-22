class Search::Movie < Search::Base
  attr_accessor :search_words

  def initialize(search_words:)
    self.search_words = search_words
  end

  def query
    {
      query: {
        multi_match: {
          fields: %w(
            title^10 key categories.name^9 categories.full_name^9
            video_artist.channel video_artist.title video_artist.editor_description
            video_artist.description video_artist.kana
          ),
          type: 'cross_fields',
          query: search_words,
          operator: 'and',
        },
      },
    }
  end

  private

  def model
    ::Movie
  end
end
