class User < ActiveRecord::Base
    has_many :meals
    has_many :veggies, through: :meals
    has_many :protiens, through: :meals
    has_many :grain, through: :meals

    def bmr_calc
        if self.sex == "M"
            bmr = 66 + (6.3 * self.weight) + (12.9 * self.height) - (6.8 * self.age)
            if self.activity == 1
                bmr *= 1.2
            elsif self.activity == 2
                bmr *= 1.55
            else
                bmr *= 1.9
            end
        else 
            bmr = 665 + (4.3 * self.weight) + (4.7 * self.height) - (4.7 * self.age)
            if self.activity == 1
                bmr *= 1.2
            elsif self.activity == 2
                bmr *= 1.55
            else
                bmr *= 1.9
            end
        end
        bmr.floor
    end

    
end
