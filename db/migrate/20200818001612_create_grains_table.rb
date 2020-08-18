class CreateGrainsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :grains do |t|
      t.string :name 
      t.integer :calories
    end
  end
end
