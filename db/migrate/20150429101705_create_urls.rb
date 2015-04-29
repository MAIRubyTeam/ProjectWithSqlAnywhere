class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :url_pattern
      t.string :name
      t.integer :url_type_id
      t.integer :sorder
    end
  end
end
