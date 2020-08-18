class CreateProteinsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :proteins do |t|
      t.string :name 
      t.integer :calories
    end
  end
end
  