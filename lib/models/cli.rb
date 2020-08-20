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

    def prompt_select(prompt, choices)
        @prompt.select(prompt, choices, per_page: 7, filter: true)
    end

    def sign_in_menu
        prompt_select("Welcome to MealPlanner! \n\n What kind of user are you?", sign_in_choices)
    end

    def sign_in_choices
        {"1. New user": -> { get_and_create_user_info },
         "2. Existing user": -> { find_existing_user }, 
         "3. Sign in as guest": -> {3}} #need method for guest sign in
    end

    def find_existing_user
        #puts "Enter your username:"
        name = @prompt.ask("Enter your username:")
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
        prompt_select("Hello #{@user.name}, what would you like to do?", main_menu_choices)
    end

    def main_menu_choices
        {
            "1. Add a new meal!": -> { create_or_select_meal },
            "2. Create a meal plan!": 2,  # <---list of meals
            "3. Change a meal!": 3, # <--- update a user meal
            "4. Change user info.": 4, #< -- update user info or delete user
            "5. Quit Mealplanner": -> { quit }
        }
    end

    def create_or_select_meal
        prompt_select("Would you like to make your own meal, or choose another user-created meal?", create_or_select_meal_choices)
    end

    def create_or_select_meal_choices
        {
            "Create my own meal!": -> { create_meal }, 
            "Pick a user created meal": -> { select_a_meal }
        }
    end

    def select_a_meal
        prompt_select("Select a user-created meal!", Meal.all.map {|meal| meal.name})
        # make the existing meal become the new user's meal
        main_menu
    end

    def create_meal
        protein = select_protein
        veggie = select_veggie
        grain = select_grain
        name = @prompt.ask("What would you like to call your meal?")
        meal = Meal.create(name: name, protein: protein, grain: grain, veggie: veggie, user: self.user)
        meal.display_meal
        main_menu
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
        @user = User.new(name: get_name, age: get_age, weight: get_weight, height: get_height, sex: get_sex, activity: get_activity)
        @user.bmr = @user.bmr_calc
        puts "Thank you! Based on your information your maximum daily caloric intake should be #{@user.bmr}."
        @user.save
        @user
    end

    def meal_plan_intro
        puts "Let's create a meal plan!"
    end

    def select_protein
        selection = prompt_select("Please select a protein:", Protein.order(:name).print_names)
        Protein.find_by(name: selection)
    end

    def select_veggie
        selection = prompt_select("Please select a vegtable", Veggie.order(:name).print_names)
        Veggie.find_by(name: selection)
    end

    def select_grain
        selection = prompt_select("Please select a grain:", Grain.order(:name).print_names)
        Grain.find_by(name: selection)
    end
    
  
    def quit
        puts "Goodbye!"
        $running = false
    end
    
end