require_relative 'config/environment'

$running = true

while $running == true do
    cli = Cli.new

    @user = cli.sign_in_menu

    cli.main_menu


end

binding.pry





