require 'singleton'

class Glimte::CreateView
  include Glimte::Utils::Attr
  include Glimte::Utils::Callable

  class RecursiveViewCall < StandardError; end

  class TemplateNotFound < StandardError; end

  init_with_attributes :view_path, :args, :block

  def call
    # TODO: it may cause false alarms if called from different threads. Better solution?
    if ViewsBacktrace.instance.include?(view_path)
      raise RecursiveViewCall, "Template #{view_path} seems to be calling itself. "\
                               "Backtrace:\n   #{view_path}\n#{ViewsBacktrace.instance.map { |view_path| "<- #{view_path}" }.join("\n") }"
    end
    ViewsBacktrace.instance.push(view_path)

    view_abs_path = Glimte.path('app/views').join("#{view_path}.glimmer.rb")
    raise TemplateNotFound, "Can't find template #{view_abs_path}" unless File.exist?(view_abs_path)

    view_model_abs_path = Glimte.path('app/views').join("#{view_path}.rb")
    view_model_instance =
      if File.exist?(view_model_abs_path)
        view_model_class_name = 'ViewModels::' + view_path.to_s.split('/').map { |n| n.camelcase(:upper) }.join('::')
        view_model_class_name.safe_constantize&.new
      end

    container = CreateContainer.call(_container_type: container_type,
                                     _view_path: view_path,
                                     _view_model_instance: view_model_instance,
                                     _header_block: block)

    begin
      Glimte::RenderView.call(_container: container,
                              _view_path: view_path,
                              _view_model_instance: view_model_instance,
                              _body_block: (Glimte::Dev::Scene.scenario_for(view_path) if Glimte::Dev::Scene.watched?))
    rescue Glimte::RenderView::ErrorInTemplate => e
      if Glimte::Dev::Scene.watched?
        ViewsBacktrace.instance.clear
        Glimte::Dev::Scene.show_render_error(e)
      else
        # TODO: Framework.exit(by_exception: e)
        raise
      end
    else
      ViewsBacktrace.instance.pop
      Glimte::Dev::Scene.patch_glimmer_container(container) if Glimte::Dev::Scene.watched?
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

  # def component_name
  #   view_path.split('/').map { |part| part.camelcase(true) }.join('/')
  # end

  class ViewsBacktrace < Array
    include Singleton

    def from_main_window?
      self.any? && self.first.to_s == 'main_window'
    end
  end

  class CreateContainer
    include Glimmer
    include Glimte::Utils::Attr
    include Glimte::Utils::Callable

    init_with_attributes :_container_type, :_view_path, :_view_model_instance, :_header_block

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
      container.instance_attr_reader(:view_path, _view_path)
      container.instance_attr_reader(:view_model, _view_model_instance)
      container.content(&_header_block) if _header_block
      container
    end

  end

end
