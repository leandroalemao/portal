class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :nome
      t.string :responsavel
      t.string :descricao

      t.timestamps
    end
  end
end
