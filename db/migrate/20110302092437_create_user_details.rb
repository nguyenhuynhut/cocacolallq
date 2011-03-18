class CreateUserDetails < ActiveRecord::Migration
  def self.up
    create_table :user_details do |t|
      t.string :real_name
      t.string :street_address
      t.integer :city_id
      t.integer :state_id
      t.integer :post_code
       t.string :avatar
      t.string :gender
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_details
  end
end
