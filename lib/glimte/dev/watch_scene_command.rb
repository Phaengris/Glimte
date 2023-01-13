require 'tty-option'

class Glimte::Dev::WatchSceneCommand
  include TTY::Option

  usage do
    no_command
    desc "Run application in \"watch scene\" mode"
    example "watch_scene open_settings_window"
  end

  argument :scene do
    required
    desc "Path to the scene inside dev/scenes directory (you may omit .rb)"
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
      puts "#{params.errors.summary}\n\n#{help}"
      exit 1
    end
  end

end