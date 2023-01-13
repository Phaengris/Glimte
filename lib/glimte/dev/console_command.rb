require 'tty-option'

class Glimte::Dev::ConsoleCommand
  include TTY::Option

  usage do
    no_command
    desc "Run application in \"console\" mode"
    example "console\n  (starts interactive mode)"
    example "console \"Views.MainWindow.open\"\n  (opens the application's main window)"
    example "echo \"Views.MainWindow.open\" | console\n  (does the same as above)"
    example "A simple keyboard event catcher:\n  console \"include Glimmer; root { on(\\\"KeyPress\\\") { |e| pp e } }.open\""
  end

  argument :script do
    optional
    desc <<DESC.strip
A string to evaluate. If provided, interactive mode isn't started, but the script is evaluated and the output is printed.
Passing a string through pipeline is processed the same way.
DESC
  end

  option :help do
    short '-h'
    long '--help'
    desc "Print usage"
  end

  def run
    parse

    case
    when params[:help]
      puts help
      exit 0
    when !params.valid?
      puts params.errors.summary
      exit 1
    end
  end

end