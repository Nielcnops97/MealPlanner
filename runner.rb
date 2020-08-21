require_relative 'config/environment'

$running = true
cli = Cli.new

while $running == true do
    if cli.user == nil 
        @user = cli.sign_in_menu
    end
    cli.main_menu if $running == true
end