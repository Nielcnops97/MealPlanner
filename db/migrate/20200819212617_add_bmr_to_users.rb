class AddBmrToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bmr, :integer
  end
end
