class User < ActiveRecord::Base
    has_many :meals
    has_many :veggies, through: :meals
    has_many :protiens, through: :meals
    has_many :grain, through: :meals
end