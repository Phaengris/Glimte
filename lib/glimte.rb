# TODO: why it isn't requested by Glimmer itself? am I missing something?
require 'concurrent'

require 'glimmer'
require 'glimmer-dsl-tk'

# TODO: well, should we get rid of ActiveSupport?
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/module/delegation'
require 'active_support/concern'

module Glimte
  def self.run(**boot_args)
    boot(**boot_args)
    Views.MainWindow.open
  end

  def self.boot(root_path: nil)
    root_path ||= begin
                    match = caller[1].match /^(.*):[0-9]+:in \`/
                    raise "Failed to detect application root path. Try to use `root_path` parameter to specify it." unless match
                    File.dirname(match[1])
                  end
    @root = Pathname.new(root_path)

    Glimte::Boot.call
  end

  def self.root
    @root.dup
  end

  def self.path(local_path)
    @root.join(local_path)
  end

  def self.views_path
    path('app/views')
  end

  def self.view_path(path)
    views_path.join(path)
  end

  def self.assets_path
    path('app/assets')
  end

  def self.asset_path(path)
    assets_path.join(path)
  end

  def self.exit
    # TODO: exit callbacks?
    Views.MainWindow.destroy if Views.main_window_ready?
    Kernel.exit
  end

  module Utils; end
  module Dev; end
end

require_relative './glimte/utils/attr'
require_relative './glimte/utils/callable'

Dir[File.expand_path(File.dirname(__FILE__) + '/glimmer/**/*.rb')].each { |f| require f }
::Glimmer::Tk::WidgetProxy.include Glimte::Utils::Attr

# TODO: should we move it under Glimte:: namespace?
require_relative './views'
require_relative './view_models'

# TODO: make all internal functionality classes private?
Dir[File.expand_path(File.dirname(__FILE__) + '/glimte/**/*.rb')].each { |f| require f }
