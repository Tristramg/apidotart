class CreatePaths < ActiveRecord::Migration
  def self.up
    create_table :paths do |t|
      t.string :path_id
      t.string :rmn_id
      t.string :url
      t.string :origin_value
      t.string :origin_key
      t.timestamps
    end
  end

  def self.down
    drop_table :paths
  end
end
