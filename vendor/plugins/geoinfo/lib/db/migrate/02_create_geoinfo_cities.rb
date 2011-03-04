class CreateGeoinfoCities < ActiveRecord::Migration
  def self.up
    create_table :geoinfo_cities do |t|
      t.string :name
      t.integer :state_id
      t.integer :gnis_id
      t.float :latitude
      t.float :longitude
      t.integer :population_2000

      t.timestamps
    end
  end

  def self.down
    drop_table :geoinfo_cities
  end
end
