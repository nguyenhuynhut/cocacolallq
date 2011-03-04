class CreateUserDetails < ActiveRecord::Migration
  def self.up
    create_table :user_details do |t|
      t.string :real_name
      t.string :street_address
      t.string :city
      t.string :state
      t.integer :post_code
      t.string :paypal_account
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_details
  end
end
