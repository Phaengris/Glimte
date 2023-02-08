name 'run'
aliases 'r'
usage 'run [options]'
summary 'Start application'

flag :h, :help, 'Show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

flag :d, :dev, 'Start in development mode (watch for changes in your models / views, reload the application accordingly)'

option :s, :scenario, <<-DESC
  When your application is reloaded in development mode, it opens the root window only.\
  Put a scenario in dev/scenarios and specify it with this option to re-open the window / re-create the state you want to work on.
  Ignored unless development mode.
DESC

# TODO: --view-scenario option (an equivalent of `scenario_for` in scenario files) for quickly defining a small scenario

# TODO: --root-path option?

run do |opts, args, cmd|
  require 'glimte'

  if opts[:dev]
    Glimte::Dev::Runner.instance.run(scenario_path: opts[:scenario])
  else
    Glimte.run
  end
end
