require_relative 'config/environment'

cli = Cli.new

cli.sign_in_menu



binding.pry
protein = cli.select_protein
veggie = cli.select_veggie
grain = cli.select_grain
cli.create_meal protein, grain, veggie, cli.user


binding.pry







