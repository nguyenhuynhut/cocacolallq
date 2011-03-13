class CreateCriteriaActivities < ActiveRecord::Migration
  def self.up
    create_table :criteria_activities do |t|
      t.references :liquor_license
      t.references :user
      t.date :expiration_date
      t.boolean :status

      t.timestamps
    end
  end

  def self.down
    drop_table :criteria_activities
  end
end
