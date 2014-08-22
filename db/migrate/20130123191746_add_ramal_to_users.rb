class AddRamalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :branch, :string
    add_column :users, :phone, :string
  end
end
