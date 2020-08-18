class Cli
    attr_accessor :user

    def initialize user=nil
        @user
    end
    # plan to initialize user in order to have an individual user sign in again after closing the app.

    def greet_user
        puts "Welcome to MealPlanner, please enter your username:" # <-- add method to find existing user
        name = gets.strip      
    end

    def get_and_create_user_info(name)
        puts "Hello #{name}! Please input your age:"
        age = (gets.strip).to_i # <-- make method to check age
        puts "Thank you, please enter your height in inches:"
        height = (gets.strip).to_i
        puts "Thank you, please enter your weight:"
        weight = (gets.strip).to_i
        puts "Thank you, please enter you sex:  M/F"
        sex = gets.strip # <-- add sex checker
        puts "Thank you, how would you rate your physical activity on a scale of 1-3?"
        puts "1. I'm fairly sedentary."
        puts "2. I exercise a couple times a week."
        puts "3. I exercise nearly every day."
        activity = (gets.strip).to_i
        @user = User.create(name: name, age: age, weight: weight, height: height, sex: sex, activity: activity)
        bmr = user.bmr_calc
        puts "Thank you! Based on your information your maximum daily caloric intake should be #{bmr}."
        @user
    end

    def meal_plan_intro
        puts "Let's create a meal plan!"
    end

    def select_protein
        puts "Please select a proteins:"
        Protein.print_names
        selection = gets.strip
        Protein.find_by(name: selection)
    end

    def select_veggie
        puts "Please select a vegetable:"
        Veggie.print_names
        selection = gets.strip
        Veggie.find_by(name: selection)
    end

    def select_grain
        puts "Please select a grain:"
        Grain.print_names
        selection = gets.strip
        Grain.find_by(name: selection)
    end
    
    def create_meal protein, grain, veggie, user
        puts "What would you like to call your meal?"
        name = gets.strip
        puts "loading..."
        puts "..."
        meal = Meal.create(name: name, protein: protein, grain: grain, veggie: veggie, user: user)
        binding.pry
        meal.display_meal
        binding.pry
    end

    def find_user(name)
        User.all.find_by(name: name)   
    end

    
end