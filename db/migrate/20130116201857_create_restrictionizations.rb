class CreateRestrictionizations < ActiveRecord::Migration

  def change
    create_table :restrictionizations do |t|
      t.integer :restriction_id
      t.integer :mailing_id

      t.timestamps
    end
  end

end
