class CreateBidActivities < ActiveRecord::Migration
  def self.up
    create_table :bid_activities do |t|
      t.references :liquor_license_auction
      t.references :user
      t.date :expiration_date
      t.boolean :status

      t.timestamps
    end
  end

  def self.down
    drop_table :bid_activities
  end
end
