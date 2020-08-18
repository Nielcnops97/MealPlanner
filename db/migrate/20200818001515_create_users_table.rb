class CreateUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.string :sex
      t.integer :weight
      t.integer :height
      t.integer :activity
    end   
  end
end
