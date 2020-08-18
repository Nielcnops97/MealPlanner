require_relative 'config/environment'

cli = Cli.new

name = cli.greet_user
#check all users and if name == a user.name then @user = user
user = cli.get_and_create_user_info(name)
protein = cli.select_protein
veggie = cli.select_veggie
grain = cli.select_grain
cli.create_meal protein, grain, veggie, user




binding.pry







