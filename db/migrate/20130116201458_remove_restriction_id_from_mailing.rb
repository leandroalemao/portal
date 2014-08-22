class RemoveRestrictionIdFromMailing < ActiveRecord::Migration
  def up
    remove_column :mailings, :restriction_id
  end

  def down
    add_column :mailings, :restriction_id, :integer
  end
end
