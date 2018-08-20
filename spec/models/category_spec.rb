require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '#root?' do
    subject { category.root? }

    context 'when the category is root' do
      let(:category) { create(:category, :root) }

      it { is_expected.to be true }
    end

    context 'when the category is child' do
      let(:root_category) { create(:category, :root) }
      let(:category) { create(:category, parent_id: root_category.id) }

      it { is_expected.to be false }
    end
  end

  describe '#movie_registration_definitions' do
    let(:category) { create(:category, :category_97) }
    let(:video_artist) { create(:video_artist, :softvolley) }
    let!(:movie_registration_definition) {
      create(:movie_registration_definition, video_artist: video_artist, category: category)
    }

    it 'movie_registration_definitions are also destroyed' do
      expect { category.destroy }.to change {
        category.movie_registration_definitions.count
      }.from(1).to(0)
    end
  end
end
