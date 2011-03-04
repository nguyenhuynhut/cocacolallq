ActiveRecord::Schema.define(:version => 0) do
    create_table :geoinfo_states, :force => true do |t|
      t.string :name
      t.string :abbr
      t.string :country
      t.string :type
    end
    create_table :geoinfo_cities, :force => true do |t|
      t.string :name
      t.integer :state_id
      t.integer :gnis_id
      t.float :latitude
      t.float :longitude
      t.integer :population_2000
    end

end
