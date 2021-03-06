class CreateLiquorLicenses < ActiveRecord::Migration
  def self.up
    create_table :liquor_licenses do |t|
      t.string :title
      t.string :location
      t.string :state
      t.string :city
      t.string :url
      t.float :price
      t.date :expiration_date

      t.timestamps
    end
  end

  def self.down
    drop_table :liquor_licenses
  end
end
