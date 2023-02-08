require 'dry-initializer'
require 'forwardable'
require_relative './view_helpers'

class Glimte::RenderView
  extend Dry::Initializer
  extend Forwardable
  include Glimmer
  include Glimte::Util::Callable
  include Glimte::ViewHelpers

  param :_container
  param :_view_path
  param :_view_model_instance
  param :_body_block

  def_delegators :_container,
                 :raise_event, :action, :cancel, :close_window

  def call
    define_singleton_method :view_model do; _view_model_instance; end
    define_singleton_method File.basename(_view_path).to_sym do; _view_model_instance; end
    define_singleton_method :view do; _container; end
    define_singleton_method :widget do; _container; end

    Dir.glob(Glimte.path('app/views')
                   .join("#{_view_path}_components/_*.glimmer.rb")).each do |component_abs_path|
      component_method_name = File.basename(component_abs_path, '.glimmer.rb').delete_prefix('_')
      # TODO: catch errors, replace "eval" with component_abs_path
      eval "define_singleton_method :#{component_method_name} do\n#{File.read(component_abs_path)}\nend"
    end

    # TODO: _container.clear! ?
    begin
      _view_abs_path = Glimte.path("app/views").join("#{_view_path}.glimmer.rb")
      _container.content do
        instance_eval(File.read(_view_abs_path))
        _body_block.call if _body_block
      end

    rescue StandardError, SyntaxError, NoMethodError => e
      # (eval):8:in `block in initialize'
      line_before_eval = e.backtrace.find_index { |line| line.include?(__FILE__) }
      error_message = if line_before_eval.nil?
                        "Failed to render a view: #{e.class} / #{e} in #{_view_abs_path} (can't detect line number)"
                      else
                        failure_line_number = e.backtrace[line_before_eval - 1].split(':', 3)[1]
                        if failure_line_number&.match? /^[0-9]+$/
                          "Failed to render a view: #{e.class} / #{e} in #{_view_abs_path}:#{failure_line_number}"
                        else
                          "Failed to render a view: #{e.class} / #{e} in #{_view_abs_path} (can't detect line number)"
                        end
                      end
      # TODO: how to show it better?
      puts error_message
      e.backtrace.each { |line| puts "  #{line}" }
      raise ErrorInTemplate.new(error_message, _container)
    else
      # TODO: add some colorization
      puts "Rendered #{_view_abs_path}" if Glimte::Dev::Runner.instance.running?
    end
  end

  class ErrorInTemplate < StandardError
    attr_accessor :container
    private :container=
    def initialize(msg = nil, failed_container)
      self.container = failed_container
      super(msg)
    end
  end

end

class Glimte
  private_constant :RenderView
end