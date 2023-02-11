require 'zeitwerk'

class Glimte::Boot
  include Glimte::Utils::Callable

  def call
    raise "#{Glimte.views_path} must exist and be a directory" unless File.directory?(Glimte.views_path)

    loader = Zeitwerk::Loader.new
    loader.push_dir(Glimte.path('lib')) if File.directory?(Glimte.path('lib'))
    loader.push_dir(Glimte.path('app/models')) if File.directory?(Glimte.path('app/models'))
    loader.push_dir(Glimte.views_path, namespace: ViewModels)
    loader.ignore(Glimte.path('app/views/**/*.glimmer.rb'))
    loader.enable_reloading if Glimte::Dev::Runner.instance.running?
    loader.setup

    Dir[Glimte.path('app/initializers/*.rb')].sort.each { |f| require f }
  end
end

class Glimte
  private_constant :Boot
end
