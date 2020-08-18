class Grain < ActiveRecord::Base
    has_many :meals
    has_many :users, through: :meals

    def self.print_names
        all.map {|grain| puts grain.name}
    end


end
