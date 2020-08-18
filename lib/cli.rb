class Cli

    def greet_user
        puts "Welcome to MealPlanner, please enter your username:"
        name = gets.strip      
    end

    def get_info(name)
        puts "Hello #{name}! Please input your age:"
        age = (gets.strip).to_i
        # if age.class != Integer 
        #     get_info name
        # end
        puts "Thank you, please enter your height:"
    end

    def menu

    end


end