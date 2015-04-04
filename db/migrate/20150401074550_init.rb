class Init < ActiveRecord::Migration
  def up
    create_table :renew_url_type do |t|
      t.string :name
      t.index :name, unique: true
    end
    
    create_table :renew_user_group do |t|
      t.string :name
      t.index :name, unique: true
    end
    
    create_table :renew_users do |t|
      t.string :name
      t.index :name, unique: true
    end
    
    create_table :renew_users_groups do |t|
      t.integer :renew_user_id
      t.integer :renew_user_group_id
      t.index [:renew_user_id, :renew_user_group_id], unique: true, name: "index_users_groups_on_user_id_and_user_group_id"
    end
    
    create_table :renew_url do |t|
      t.string :url_pattern
      t.string :name
      t.integer :url_type_id
      t.integer :sorder
    end
    
    create_table :renew_users_urls do |t|
      t.integer :renew_user_group_id
      t.integer :renew_user_url_id
      t.index [:renew_user_group_id, :renew_user_url_id], unique: true, name: "index_users_urls_on_user_group_id_and_url_id"
    end
    
    create_table :renew_menu_tree, id: false do |t|
      t.integer :id
      t.integer :parent
      t.index [:id, :parent], unique: true
    end
    
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
      
      t.index :session_id, :unique => true
      t.index :updated_at
    end
    
    create_table :renew_page_content do |t|
      t.integer :page_part_id
      t.integer :renew_url_id
      t.text :html
      t.integer :width
      t.integer :height
    end
  end
  
  def down
    
  end
end
