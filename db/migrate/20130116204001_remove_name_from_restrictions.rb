class RemoveNameFromRestrictions < ActiveRecord::Migration
  def up
    remove_column :restrictions, :name
  end

  def down
    add_column :restrictions, :name, :integer
  end
end
