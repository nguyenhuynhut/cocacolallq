class CreateLiquorLicenses < ActiveRecord::Migration
  def self.up
    create_table :liquor_licenses do |t|
      t.string :title
      t.string :location
      t.integer :state_id
      t.integer :city_id
      t.string :url
      t.float :price
      t.date :expiration_date
      t.string :from_host
      t.string :purpose
      t.string :email
      t.references :user
      t.references :buyer
      t.references :license_type
      t.timestamps
    end
  end

  def self.down
    drop_table :liquor_licenses
  end
end
