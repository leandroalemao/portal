class CreateMailings < ActiveRecord::Migration
  def change
    create_table :mailings do |t|
      t.string :typemailing
      t.string :approach
      t.text :objective
      t.text :description
      t.text :sms
      t.text :folder
      t.text :layout
      t.text :periodicity
      t.integer :user_id
      t.integer :restriction_id
      t.integer :prowner_id
      t.integer :inowner_id
      t.integer :rlowner_id
      t.integer :atowner_id
      t.integer :plowner_id
      t.string :slug

      t.timestamps
    end
  end
end
