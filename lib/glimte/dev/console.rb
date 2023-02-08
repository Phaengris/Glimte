require 'singleton'

class Glimte::Dev::Console
  # let it be a singleton to prevent starting another console instance inside the console
  include Singleton

  class AlreadyRunning < StandardError; end

  def run
    raise AlreadyRunning if running?

    Glimte.instance.boot

    interactive = true

    if STDIN.stat.pipe?
      STDIN.each_line do |script|
        eval(script)
      end
      interactive = false
    end

    unless (argv = ARGV[1..-1]).empty? # there's always ["console"]
      argv.each do |script|
        eval(script)
      end
      interactive = false
    end

    exit unless interactive

    require 'irb'

    puts "Welcome to the Glimte console!"
    # TODO: show Glimte version etc?
    ARGV.clear
    IRB.start
  end

  private

  def running?
    IRB.conf.present?
  end
end
