require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/glimmer")
loader.ignore("#{__dir__}/dev/commands")
loader.setup

require 'glimmer'
require 'glimmer-dsl-tk'

require 'singleton'
require 'facets/kernel/present'

class Glimte
  include Singleton

  class AlreadyRunning < StandardError; end
  class AlreadyBooted < StandardError; end

  class << self
    def_delegator :run, :instance
  end

  attr_reader :root,
              :views

  def run(**boot_args)
    raise AlreadyRunning if running?

    boot(**boot_args)
    @views.MainWindow.open
  end

  def boot(root_path: nil)
    raise AlreadyBooted if booted?

    root_path ||= Glimte::FindRoot.call
    raise ApplicationRootNotFound unless root_path

    @root = Pathname.new(root_path)
    @views = Glimte::Views.new
    Glimte::Boot.call
  end

  def self.root
    instance.root.dup
  end

  def self.path(local_path)
    @root.join(local_path)
  end

  def self.views_path
    path('app/views')
  end

  def self.view_path(path)
    path += '.glimmer.rb' unless path.end_with?('.glimmer.rb')
    views_path.join(path)
  end

  def self.assets_path
    path('app/assets')
  end

  def self.asset_path(path)
    assets_path.join(path)
  end

  def self.exit(code = 0)
    instance.views.MainWindow.destroy if instance.views.main_window_ready?
    Kernel.exit(code)
  end

  private

  def running?
    @views&.main_window_ready?
  end

  def booted?
    @root.present?
  end
end

Dir[File.expand_path(File.dirname(__FILE__) + '/glimmer/**/*.rb')].each { |f| require f }
