class CreateGeoinfoStates < ActiveRecord::Migration
  def self.up
    create_table :geoinfo_states do |t|
      t.string :name
      t.string :abbr
      t.string :country
      t.string :kind

      t.timestamps
    end
  end

  def self.down
    drop_table :geoinfo_states
  end
end
