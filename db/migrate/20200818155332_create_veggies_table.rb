class CreateVeggiesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :veggies do |t|
      t.string :name 
      t.integer :calories
    end
  end
end
