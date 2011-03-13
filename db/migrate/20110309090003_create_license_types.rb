class CreateLicenseTypes < ActiveRecord::Migration
  def self.up
    create_table :license_types do |t|
      t.string :license_code
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :license_types
  end
end
