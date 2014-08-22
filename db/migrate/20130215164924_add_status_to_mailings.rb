class AddStatusToMailings < ActiveRecord::Migration
  def change
    add_column :mailings, :status, :integer
  end
end
