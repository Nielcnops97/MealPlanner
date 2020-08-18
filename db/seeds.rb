Grain.destroy_all
Protein.destroy_all
User.destroy_all
Veggie.destroy_all
Meal.destroy_all

brown_rice = Grain.create(name: "Brown Rice", calories: 150)
chicken = Protein.create(name: "Chicken", calories: 220)
carrot = Veggie.create(name: "Carrot", calories: 60)
charlie = User.create(name: "Charlie", age: 25, sex: "M", height: 132, weight: 182, activity: 2)
lunch = Meal.create(name: "Lunch", protein: chicken, veggie: carrot, grain: brown_rice, user: charlie)
