class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'postgis'

    create_table :locations do |t|
      t.references :movie, null: false
      t.st_point :lonlat, geographic: true, null: false

      t.timestamps null: false
    end
  end
end
