class Protein < ActiveRecord::Base
    has_many :meals
    has_many :users, through: :meals

    def self.print_names
        all.map {|protein| puts protein.name}
    end

    
end

