class Meal < ActiveRecord::Base
    belongs_to :user
    belongs_to :veggie
    belongs_to :protein
    belongs_to :grain
    has_many :proteins
    has_many :veggies
    has_many :grains

    attr_writer :protein, :veggie, :grain

    def calorie_count
        self.protein.calories + self.grain.calories + self.veggie.calories
    end

    def display_meal
        puts "#{self.protein.name} with #{self.veggie.name}, and #{self.grain.name}"
        puts "Your meal's total calorie count is #{self.calorie_count}."
    end

end

