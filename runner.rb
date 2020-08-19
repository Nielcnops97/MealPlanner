require_relative 'config/environment'

cli = Cli.new

name = cli.greet_user
if cli.find_user(name)
    cli.user = cli.find_user(name)
else
    cli.user = cli.get_and_create_user_info(name)
end
#check all users and if name == a user.name then @user = user
binding.pry
protein = cli.select_protein
veggie = cli.select_veggie
grain = cli.select_grain
cli.create_meal protein, grain, veggie, cli.user




binding.pry







