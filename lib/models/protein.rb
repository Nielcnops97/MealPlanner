class Protein < ActiveRecord::Base
    has_many :meals
    has_many :users, through: :meals

    def self.print_names
        all.map {|protein|  protein.name}
    end

    
end

