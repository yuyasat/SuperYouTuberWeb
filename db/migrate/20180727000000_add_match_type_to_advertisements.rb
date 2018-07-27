class AddMatchTypeToAdvertisements < ActiveRecord::Migration[5.1]
  def change
    add_column :advertisements, :match_type, :integer, null: false, default: 1
  end
end
