class Meal < ActiveRecord::Base
    belongs_to :user
    belongs_to :veggie
    belongs_to :protein
    belongs_to :grain
end

