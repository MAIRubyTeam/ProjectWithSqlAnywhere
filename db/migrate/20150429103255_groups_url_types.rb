class GroupsUrlTypes < ActiveRecord::Migration
  def change
  	create_table :groups_url_types do |t|
  		t.references :url_type
  		t.references :group
  	end
  end
end
