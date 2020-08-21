class Grain < ActiveRecord::Base
    has_many :meals
    has_many :users, through: :meals

    def self.print_names
        all.map {|grain| grain.name}
    end
end
