class CreateLiquorLicenseAuctions < ActiveRecord::Migration
  def self.up
    create_table :liquor_license_auctions do |t|
      t.float :price
      t.references :liquor_license
      t.references :user
      t.references :bidder
      t.boolean :status
      t.timestamps
    end
  end

  def self.down
    drop_table :liquor_license_auctions
  end
end
