class AddColumnsToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :published_at, :datetime
    add_column :movies, :channel, :string
  end
end
