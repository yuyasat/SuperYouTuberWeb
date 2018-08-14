class AddAutoRegisteredToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :registered_type, :integer, null: false, default: 1
  end
end
