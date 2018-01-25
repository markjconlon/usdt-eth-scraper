class CreateTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :trades do |t|
      t.string :sell_exchange
      t.decimal :sell_rate
      t.string :buy_exchange
      t.decimal :buy_rate
      t.decimal :amount
      t.decimal :rate_above_break_even
      
      t.timestamps
    end
  end
end
