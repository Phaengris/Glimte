require 'zeitwerk'

class Glimte::Boot
  include Glimte::Utils::Callable

  def call
    raise "#{Glimte.path('app/views')} must exist and be a directory" unless File.directory?(Glimte.path('app/views'))

    loader = Zeitwerk::Loader.new
    loader.push_dir(Glimte.path('lib')) if File.directory?(Glimte.path('lib'))
    loader.push_dir(Glimte.path('app/models')) if File.directory?(Glimte.path('app/models'))
    loader.push_dir(Glimte.path('app/views'), namespace: ViewModels)
    loader.ignore(Glimte.path('app/views/**/*.glimmer.rb'))
    loader.enable_reloading # TODO: make it dev mode only
    loader.setup

    Dir[Glimte.path('app/initializers/*.rb')].sort.each { |f| require f }
  end
end
