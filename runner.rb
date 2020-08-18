require_relative 'config/environment'

cli = Cli.new
name = cli.greet_user
cli.get_info name
binding.pry







