class CreateAdvertisements < ActiveRecord::Migration[5.1]
  def change
    create_table :advertisements do |t|
      t.string :path, null: false
      t.integer :device, null: false, default: 3
      t.integer :location, null: false
      t.jsonb :target, default: nil
      t.datetime :start_at, null: false
      t.datetime :end_at

      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
