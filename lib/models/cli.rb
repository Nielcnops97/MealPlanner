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

    def sign_in_menu
        prompt_select("Welcome to MealPlanner! \n\nWhat kind of user are you?", sign_in_choices)
    end

    def sign_in_choices
        {"1. New user": -> { get_and_create_user_info }, "2. Existing user": -> { find_existing_user }, "3. Sign in as guest": -> {3}}
    end

    def find_existing_user
        puts "Enter your username:"
        name = @prompt.ask
        if !find_user(name)
            puts "Invalid user, please try again."
            find_existing_user
        end
        @user = find_user(name)
    end

    def find_user(name)
        User.all.find_by(name: name)   
    end

    def main_menu
        puts "What would you like to do?"
        # Change user info
        # Change my meals
        # Delete my meals
        # make new Meal
        # Create a meal plan
    end

    def activity_choices
        {"1. I'm fairly sedentary.": 1, "2. I exercise a couple times a week.": 2, "3. I exercise nearly every day.": 3}
    end

    def get_name
        (@prompt.ask("Please enter your new username:"))
    end

    def get_age
        (@prompt.ask("Please input your age:")).to_i
    end

    def get_height
        (@prompt.ask("Thank you, please enter your height in inches:")).to_i
    end

    def get_weight
        (@prompt.ask("Thank you, please enter your weight:")).to_i
    end

    def get_sex
        @prompt.ask("Thank you, please enter you sex:  M/F")
    end
    
    def get_activity
        @prompt.select("Thank you, how would you rate your physical activity on a scale of 1-3?(1 being not active)", activity_choices)
    end


    def get_and_create_user_info
        name = get_name
        age = get_age
        height = get_height
        weight = get_weight
        sex = get_sex
        activity = get_activity
        @user = User.new(name: name, age: age, weight: weight, height: height, sex: sex, activity: activity)
        @user.bmr = @user.bmr_calc
        puts "Thank you! Based on your information your maximum daily caloric intake should be #{@user.bmr}."
        @user.save
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
        meal = Meal.create(name: name, protein: protein, grain: grain, veggie: veggie, user: user)
        meal.display_meal
    end

    
    
end