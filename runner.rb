require_relative 'config/environment'

$running = true

while $running == true do

    cli = Cli.new

    cli.sign_in_menu

    cli.main_menu


    binding.pry

end







