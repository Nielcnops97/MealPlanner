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
        } 
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
            "3. Change/Delete a meal!": -> { user_meals_list }, 
            "4. Change user info.": -> { change_user_info }, 
            "5. Quit Mealplanner": -> { quit } 
        }
    end

    def user_meals_list
        meal_name = @prompt.select("Please select one of your meals", meal_with_components(user.id))
        meal = get_meal_by_name(meal_name)
        change_or_destroy_meal_select(meal)
    end

    def change_or_destroy_meal_select(meal)
        @prompt.select(
            "What would you like to do with your meal? \n\n 
            #{meal.name} -- contains: #{meal.protein.name} with #{meal.veggie.name} and #{meal.grain.name}\n\n",
            change_or_destroy(meal)
        )
    end

    def change_or_destroy(meal)
        {
            "1. Change part of the meal": -> { change_list(meal) },
            "2. Destroy meal": -> { destroy_meal(meal)},
            "3. Choose a different meal": -> { user_meals_list },
            "4. Return to main menu": -> { main_menu }
        }
    end

    def change_list(meal)
        @prompt.select("What would you like to change?", components_list(meal))
        puts "Your meal has been changed!\n\n"
        main_menu
    end

    def components_list(meal)
        {
            "1. Protein": -> {select_protein(meal)},
            "2. Veggie": -> {select_veggie(meal)},
            "3. Grain": -> {select_grain(meal)},
            "4. Back": -> { change_or_destroy_meal_select(meal) }
        }
    end

    def destroy_meal(meal)
        meal.destroy
        puts "You meal has been destroyed! Good riddance!"
        main_menu
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
            "Pick a user created meal": -> { select_a_meal },
            "Back": -> { main_menu }
        }
    end

    def meal_with_components userid=nil
        if userid
            meals = Meal.all.select {|meal| meal.user_id == userid}
            return meals.map {|meal| "#{meal.name} -- contains: #{meal.protein.name} with #{meal.veggie.name} and #{meal.grain.name}"}
        end
        Meal.all.map {|meal| "#{meal.name} -- contains: #{meal.protein.name} with #{meal.veggie.name} and #{meal.grain.name}"}
    end

    def select_a_meal
        meal_name = prompt_select("Select a user-created meal!", meal_with_components)
        meal = get_meal_by_name(meal_name)
        meal_transform(meal)
        puts "Your new meal has been added!\n\n"
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
        meal = Meal.create(name: name, protein_id: protein.id, grain_id: grain.id, veggie_id: veggie.id, user: self.user)
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

    def meal_transform meal
        puts "What would you like to call your new meal?"
        name = gets.strip
        new_meal = Meal.create(name: name, protein: meal.protein, grain: meal.grain, veggie: meal.veggie, user: self.user)
    end

    def activity_choices
        {
            "1. I'm fairly sedentary.": 1, 
            "2. I exercise a couple times a week.": 2, 
            "3. I exercise nearly every day.": 3,
            "4. I would like to restart": -> { sign_in_menu }
        }
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

    def select_protein meal=nil
        if meal
            selection = prompt_select("Please select a protein:", Protein.order(:name).print_names)
            new_protein = Protein.find_by(name: selection)
            meal.protein_id = new_protein.id
            meal.save
            return 
        end
        selection = prompt_select("Please select a protein:", Protein.order(:name).print_names)
        Protein.find_by(name: selection)
    end

    def select_veggie meal=nil
        if meal
            selection = prompt_select("Please select a veggie:", Veggie.order(:name).print_names)
            new_veggie = Veggie.find_by(name: selection)
            meal.veggie_id = new_veggie.id
            meal.save
            return 
        end
        selection = prompt_select("Please select a vegtable", Veggie.order(:name).print_names)
        Veggie.find_by(name: selection)
    end

    def select_grain meal=nil
        if meal
            selection = prompt_select("Please select a grain:", Grain.order(:name).print_names)
            new_grain = Grain.find_by(name: selection)
            meal.grain_id = new_grain.id
            meal.save
            return 
        end
        selection = prompt_select("Please select a grain:", Grain.order(:name).print_names)
        Grain.find_by(name: selection)
    end

    def quit
        puts "Goodbye!"
        $running = false
    end
end