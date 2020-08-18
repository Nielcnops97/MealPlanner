class CreateMealsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :meals do |t|
      t.references :user
      t.references :protein
      t.references :grain
      t.references :fruit_veggie
      t.string :name
    end
  end
end