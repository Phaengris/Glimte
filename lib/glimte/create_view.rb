require 'concurrent/array' unless Object.const_defined?('Concurrent::Array')
require 'dry-initializer'
require 'facets/string/modulize'
require 'singleton'

class Glimte::CreateView
  extend Dry::Initializer
  include Glimte::Utils::Callable

  class RecursiveViewCall < StandardError; end

  class TemplateNotFound < StandardError; end

  param :view_path
  param :args, optional: true
  param :block, optional: true

  def call
    # TODO: it may cause false alarms if called from different threads. Better solution?
    if ViewsBacktrace.instance.include?(view_path)
      raise RecursiveViewCall, "Template #{view_path} seems to be calling itself. "\
                               "Backtrace:\n   #{view_path}\n#{ViewsBacktrace.instance.map { |view_path| "<- #{view_path}" }.join("\n") }"
    end
    ViewsBacktrace.instance.push(view_path)

    view_abs_path = Glimte.view_path(view_path)
    raise TemplateNotFound, "Can't find template #{view_abs_path}" unless File.exist?(view_abs_path)

    view_model_abs_path = Glimte.path('app/views').join("#{view_path}.rb")
    view_model_instance =
      if File.exist?(view_model_abs_path)
        view_model_class_name = 'ViewModels::' + view_path.to_s.split('/').map(&:modulize).join('::')
        Object.const_get(view_model_class_name).new
      end

    container = CreateContainer.call(_container_type: container_type,
                                     _view_path: view_path,
                                     _view_model_instance: view_model_instance,
                                     _header_block: block)

    begin
      # TODO: why can't it refer to private subclasses from inside itself?
      Glimte.const_get('RenderView').call(
        _container: container,
        _view_path: view_path,
        _view_model_instance: view_model_instance,
        _body_block: (Glimte::Dev::Runner.instance.scenario_for(view_path) if Glimte::Dev::Runner.instance.running?)
      )
    rescue Glimte.const_get('RenderView')::ErrorInTemplate => e
      if Glimte::Dev::Runner.instance.running?
        ViewsBacktrace.instance.clear
        Glimte::Dev::Runner.instance.show_render_error(e)
      else
        # TODO: Glimte.exit ?
        raise
      end
    else
      ViewsBacktrace.instance.pop
      Glimte::Dev::Runner.instance.patch_glimmer_container(container) if Glimte::Dev::Runner.instance.running?
    end
    container
  end

  private

  def container_type
    case
    when main_window? then :root
    when window? then :toplevel
    else :frame
    end
  end

  def main_window?
    view_path.to_s == 'main_window'
  end

  def window?
    view_path.to_s.end_with?('_window')
  end

  class ViewsBacktrace < Concurrent::Array
    include Singleton

    def from_main_window?
      self.any? && self.first.to_s == 'main_window'
    end
  end

  class CreateContainer
    extend Dry::Initializer
    include Glimmer
    include Glimte::Utils::Callable

    option :_container_type
    option :_view_path
    option :_view_model_instance
    option :_header_block

    def call
      container = if _container_type == :toplevel && !ViewsBacktrace.instance.from_main_window?
                    _c = nil
                    Views.MainWindow.content do
                      _c = toplevel {}
                    end
                    _c

                  else
                    send(_container_type) {}
                  end

      # TODO: more elegant way to do this?
      container.instance_variable_set(:@_view_path, _view_path)
      container.define_singleton_method :view_path do; @_view_path; end
      container.instance_variable_set(:@_view_model_instance, _view_model_instance)
      container.define_singleton_method :view_model do; @_view_model_instance; end

      container.content(&_header_block) if _header_block
      container
    end
  end
end

class Glimte
  private_constant :CreateView
end