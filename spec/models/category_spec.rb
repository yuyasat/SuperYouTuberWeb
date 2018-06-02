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
end
