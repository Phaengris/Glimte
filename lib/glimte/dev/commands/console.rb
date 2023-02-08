name 'console'
aliases 'c'
usage 'console'
summary 'Start interactive console'
description <<-DESC
  glimte console - Just starts the console and leaves you to interact with it

  echo "some code to be executed" | glimte console - Executes the code and exits

  glimte console "some code to be executed" - Executes the code and exits
DESC

flag :h, :help, 'Show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

# TODO: --root-path option?

# TODO: --keep-interactive option - don't exit after running code from the arguments?

run do |opts, args, cmd|
  require 'glimte'

  Glimte::Dev::Console.instance.run
end
