class Cli
    attr_accessor :user

    def tty_prompt
        TTY::Prompt.new(
        symbols: { marker: '>'},
        active_color: :cyan,
        help_color: :bright_cyan
        )
    end

    def initialize user=nil
        @user
        @prompt = tty_prompt
    end
    # plan to initialize user in order to have an individual user sign in again after closing the app.

    def prompt_select(prompt, choices)
        @prompt.select(prompt, choices, per_page: 7, filter: true)
    end

    def main_menu
        prompt_select("Welcome to MealPlanner, please select from these options:", )
    end

    def greet_user
        #puts "Welcome to MealPlanner, please enter your username:" # <-- add method to find existing user
        @prompt.ask("Welcome to MealPlanner, please enter your username:")     
    end

    def activity_choices
        {"1. I'm fairly sedentary.": 1, "2. I exercise a couple times a week.": 2, "3. I exercise nearly every day.": 3}
    end


    def get_and_create_user_info(name)
        age = (@prompt.ask("Hello #{name}! Please input your age:")).to_i
        height = (@prompt.ask("Thank you, please enter your height in inches:")).to_i
        weight = (@prompt.ask("Thank you, please enter your weight:")).to_i
        sex = @prompt.ask("Thank you, please enter you sex:  M/F")
        activity = @prompt.select("Thank you, how would you rate your physical activity on a scale of 1-3?(1 being not active)", activity_choices)
        @user = User.create(name: name, age: age, weight: weight, height: height, sex: sex, activity: activity)
        bmr = user.bmr_calc
        puts "Thank you! Based on your information your maximum daily caloric intake should be #{bmr}."
        @user
    end

    def meal_plan_intro
        puts "Let's create a meal plan!"
    end

    def select_protein
        selection = prompt_select("Please select a protein:", Protein.order(:name).print_names) #need to edit print names method
        Protein.find_by(name: selection)
    end

    def select_veggie
        selection = prompt_select("Please select a vegtable", Veggie.order(:name).print_names) #need to edit print names method
        Veggie.find_by(name: selection)
    end

    def select_grain
        selection = prompt_select("Please select a grain:", Grain.order(:name).print_names)
        Grain.find_by(name: selection)
    end
    
    def create_meal protein, grain, veggie, user
        name = @prompt.ask("What would you like to call your meal?")
        meal = Meal.create(name: name, protein: protein, grain: grain, veggie: veggie, user: @user)
        meal.display_meal
    end

    def find_user(name)
        User.all.find_by(name: name)   
    end

    
end