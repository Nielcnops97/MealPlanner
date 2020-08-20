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
         "3. Sign in as guest": -> { main_menu }
        } #need method for guest sign in
    end

    def find_existing_user
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
        prompt_select("What would you like to do?", main_menu_choices)
    end

    def main_menu_choices
        {
            "1. Add a new meal!": -> { create_or_select_meal },
            "2. Create a meal plan!": -> { combine_meals},  
            "3. Change a meal!": 3, # <--- update a user meal
            "4. Change user info.": -> { change_user_info } , 
            "5. Quit Mealplanner": -> { quit }
        }
    end

    def change_user_info
        @prompt.select("Please select what info you would like to change:", user_info_choices)
    end

    def user_info_choices
        {
            "Name: (currently: #{@user.name})": -> { update_name },
            "Age: (currently: #{@user.age})": -> { update_age },
            "Sex: (currently: #{@user.sex})": -> { update_sex },
            "Weight: (currently: #{@user.weight})": -> { update_weight },
            "Height: (currently: #{@user.height})": -> { update_height },
            "Activity: (currently: #{@user.activity})": -> { update_activity },
            "Delete user:": -> { user.destroy }, #currently sends you back to sign in menu
            "Or go back to main menu:": -> { main_menu }
        }
    end

    def update_name
        @user.name = get_name
        update_bmr
    end

    def update_age
        @user.age = get_age
        update_bmr
    end

    def update_sex
        @user.sex = get_sex
        update_bmr
    end

    def update_weight
        @user.weight = get_weight
        update_bmr
    end

    def update_height
        @user.height = get_height
        update_bmr
    end

    def update_activity
        @user.activity = get_activity
        update_bmr
    end

    def update_bmr
        @user.bmr = @user.bmr_calc
        @user.save
        change_user_info

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

    def meal_with_components
        Meal.all.map {|meal| "#{meal.name} -- contains: #{meal.protein.name} with #{meal.veggie.name} and #{meal.grain.name}" }
    end

    def select_a_meal
        meal_name = prompt_select("Select a user-created meal!", meal_with_components)
        meal = Meal.all.find_by(name: meal_name)
        meal_transform(meal)
        main_menu
    end

    def get_meal_by_name(meal_name)
        meal_name = meal_name.split(' -- ')
        name = meal_name.first
        meal = Meal.all.find_by(name: name)
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

    def combine_meals
        combined_meal_names = @prompt.multi_select("Lets make a MealPlan! Select the meals you want to use:",  Meal.all.map {|meal| meal.name})
        combined_meals = combined_meal_names.map{|name| Meal.all.find_by(name: name)}
        #combine_calories combined_meals
        if combine_calories(combined_meals) > user.bmr
            puts "Total mealplan calories: #{combine_calories combined_meals}. You are #{combine_calories(combined_meals) - user.bmr} over your daily calories."
        else
            puts "Total mealplan calories: #{combine_calories combined_meals}. You are #{ user.bmr - combine_calories(combined_meals)} under your daily calories!"
        end
        main_menu
    end

    def combine_calories meals
        meals.reduce(0) {|sum, n| sum + n.calorie_count }
    end

    #sum + n.calorie_count
    def meal_transform meal
        puts "What would you like to call your new meal?"
        name = gets.strip
        new_meal = Meal.create(name: name, protein: meal.protein, grain: meal.grain, veggie: meal.veggie, user: self.user)
    end

    def activity_choices
        {"1. I'm fairly sedentary.": 1, "2. I exercise a couple times a week.": 2, "3. I exercise nearly every day.": 3}
    end

    def get_name
        @prompt.ask("Please enter your new username:", required: true) do |q|
            q.validate { |input| input =~ /^[a-zA-Z0-9_.-]*$/ }
            q.modify :strip
        end
    end

    def get_age
        @prompt.ask("Please input your age:", required: true) do |q|
            q.validate { |input| input =~ /^[0-9]*$/ }
            q.modify :to_i
        end
    end

    def get_height
        @prompt.ask("Thank you, please enter your height in inches:", required: true) do |q|
            q.validate { |input| input =~ /^[0-9]*$/ }
            q.modify :to_i
        end
    end

    def get_weight
        @prompt.ask("Thank you, please enter your weight:", required: true) do |q|
            q.validate { |input| input =~ /^[0-9]*$/ }
            q.modify :to_i
        end
    end

    def get_sex
        @prompt.ask("Thank you, please enter you sex:  M/F", required: true) do |q|
            q.validate { |input| input =~ /^[MF]*$/ && input.length == 1 }
        end
    end
    
    def get_activity
        @prompt.select("Thank you, how would you rate your physical activity on a scale of 1-3?(1 being not active)", activity_choices)
    end


    def get_and_create_user_info
        @user = User.new(name: get_name, age: get_age, weight: get_weight, height: get_height, sex: get_sex, activity: get_activity)
        @user.bmr = user.bmr_calc
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