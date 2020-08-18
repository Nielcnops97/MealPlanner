class Veggie < ActiveRecord::Base
    has_many :meals
    has_many :users, through: :meals


    def self.print_names
        all.map {|veggie| puts veggie.name}
    end

end
