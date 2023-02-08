name 'glimte'
usage 'glimte [command]'
summary 'command line utility for the Glimte framework'
description <<-DESC
  Glimte is a MVVM framework based on Glimmer for creating desktop apps in Ruby / Tk
  
  https://github.com/Phaengris/Glimte

  Run any command with the --help option to get it's usage info
DESC

# TODO: --version option - print the version and exit?

run do |opts, args, cmd|
  puts cmd.help
end
