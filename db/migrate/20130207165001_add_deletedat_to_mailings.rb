class AddDeletedatToMailings < ActiveRecord::Migration
  def change
    add_column :mailings, :deleted_at, :datetime
  end
end
