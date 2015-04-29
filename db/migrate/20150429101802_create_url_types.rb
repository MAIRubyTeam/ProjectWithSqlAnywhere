class CreateUrlTypes < ActiveRecord::Migration
  def change
    create_table :url_types do |t|
      t.string :name
      t.index :name, unique: true
    end
  end
end
