class CreateCriterias < ActiveRecord::Migration
  def self.up
    create_table :criterias do |t|
      t.integer :state_id
      t.integer :city_id
      t.references :user
      t.references :license_type
      t.timestamps
    end
  end

  def self.down
    drop_table :criterias
  end
end
