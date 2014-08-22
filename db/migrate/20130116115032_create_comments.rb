class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.integer :mailing_id

      t.timestamps
    end
  end
end
