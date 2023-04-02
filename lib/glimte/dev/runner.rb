require 'singleton'
require 'memoized'
require 'listen'

class Glimte::Dev::Runner
  include Singleton
  include Memoized
  include Glimmer

  class DevModeOnlyError < StandardError
    def initialize(msg = nil)
      msg ||= "This feature is supposed to work in development mode only. "\
              "Run `glimte run --dev` or use `Glimte::Dev::Runner` directly (not encouraged)."
      super msg
    end
  end
  class AlreadyRunning < StandardError; end

  def run(scenario: nil)
    # TODO: named error?
    raise AlreadyRunning if running? || Glimte.instance.running?
    @running = true

    Glimte.instance.boot

    @scenario_path = nil
    @scenario_abs_path = nil
    @scenario_content = nil
    @view_scenarios = nil
    @app_files_listener = nil
    @app_files_changed = nil

    if scenario
      @scenario_path = scenario.delete_suffix('.rb')
      @scenario_abs_path = Glimte.path('dev/scenarios').join("#{@scenario}.rb")
      if File.exists?(@scenario_abs_path)
        unless File.file?(@scenario_abs_path)
          raise "Scenario specified as path #{@scenario_abs_path}, but it is not a file" unless File.file?(@scenario_abs_path)
        end
      else
        puts "Scenario is not a file, executing it as a main window scenario..."
        @scenario_path = @scenario_abs_path = nil
        @scenario_content = <<-SCN
          scenario_for("main_window") do
            #{scenario}
          end
        SCN
      end
    end

    reload_app
  end

  def reload_app
    if @scenario_abs_path
      unless File.exists?(@scenario_abs_path)
        # TODO: add some colorization
        puts "Scenario file #{@scenario_abs_path} has been lost!"
        @app_files_listener&.stop
        exit 1
      end

      @view_scenarios = ScenarioEvaluator
                          .new(_scenario_content: File.read(@scenario_abs_path))
                          .instance_variable_get(:@_scenarios)
      if @view_scenarios.blank?
        # TODO: add some colorization
        puts "Warning: No view scenarios found in #{@scenario_abs_path}. Use `scenario_for` to add scenarios for views."
      end
    elsif @scenario_content
      @view_scenarios = ScenarioEvaluator
                          .new(_scenario_content: @scenario_content)
                          .instance_variable_get(:@_scenarios)
    else
      @view_scenarios = {}
    end

    start_app_files_listener
    unmemoize :scenario_for
    if Views.main_window_ready?
      reload_main_window
    else
      Views.MainWindow.open
    end
  end

  def running?
    @running
  end

  def app_files_changed?
    raise DevModeOnlyError unless running?

    @app_files_changed
  end

  memoize def scenario_for(view_pathname)
    raise DevModeOnlyError unless running?

    @view_scenarios[view_pathname.to_s]
  end

  def patch_glimmer_container(container)
    raise DevModeOnlyError unless running?

    container.content do
      container.instance_exec(&reload_shortcut_proc)
    end
  end

  # TODO: move into a separate callable?
  def show_render_error(error_instance)
    raise DevModeOnlyError unless running?

    # TODO: using Views.MainWindow here causes an infinite loop - investigate why
    main_window = error_instance.container.root_parent_proxy
    main_window.clear!
    main_window.tk.deiconify
    main_window.content do
      # make sure the message is visible
      # TODO: verify against screen size?
      width 1024
      height 1024 / 1.618 # why not? :)
      centered true
      escapable true

      l = nil
      frame {
        padding 20
        grid row: 0, column: 0, row_weight: 1, column_weight: 1
        l = label {
          grid row: 0, column: 0, row_weight: 1, column_weight: 1, sticky: 'nw'
          wraplength main_window.width - 40
          text error_instance.message
        }
      }

      on('Configure') do |event|
        if event.widget.is_a?(::Tk::Root) && l.tk.wraplength != event.width - 40
          l.tk.wraplength = event.width - 40
        end
      end
    end
    patch_glimmer_container(main_window)
  end

  private

  def start_app_files_listener
    # TODO: use Concurrent for these two?
    @app_files_listener&.stop
    @app_files_changed = false
    # TODO: whole ./app tree?
    paths_to_listen = []
    paths_to_listen << Glimte.path('app/models') if File.directory?(Glimte.path('app/models'))
    paths_to_listen << Glimte.path('app/views') if File.directory?(Glimte.path('app/views'))
    @app_files_listener = Listen.to(*paths_to_listen) do |modified, added, removed|
      unless @app_files_changed
        # TODO: add some colorization
        puts "Notice: app files change detected, the app has to be reloaded"
        @app_files_changed = true
      end

      # TODO: add some colorization
      puts "\"#{Time.now}\":"
      print_file_changes('modified', modified) if modified.any?
      print_file_changes('added', added) if added.any?
      print_file_changes('removed', removed) if removed.any?
    end
    @app_files_listener.start
  end

  def print_file_changes(change_type, paths)
    # TODO: add some colorization
    puts "  #{change_type}"
    paths.each { |path| puts "    - #{path}"}
  end

  memoize def reload_shortcut_proc
    proc {
      on('KeyPress') do |event|
        if event.keysym.downcase == 'r' && event.state == 4
          Glimte::Dev::Runner.instance.reload_app
          break false
        end
      end
      on('FocusIn') do
        if Glimte::Dev::Runner.instance.app_files_changed?
          Glimte::Dev::Runner.instance.reload_app
          break false
        end
      end
    }
  end

  def reload_main_window
    Views.MainWindow.clear!

    view_abs_path = Glimte.path('app/views/main_window.glimmer.rb')
    raise Views::MainWindowTemplateNotFoundError unless File.exist?(view_abs_path)

    view_model_path = Glimte.path('app/views/main_window.rb')
    view_model_instance = ViewModels::MainWindow.new if File.exist?(view_model_path)

    begin
      # TODO: well, I'm starting to think if it's really worth it to make them private
      # TODO: if we have to call them through `const_get` anyway
      Glimte.const_get('RenderView').call(_container: Views.MainWindow,
                              _view_path: 'main_window',
                              _view_model_instance: view_model_instance,
                              _body_block: scenario_for('main_window'))
    rescue Glimte.const_get('RenderView')::ErrorInTemplate => e
      show_render_error(e)
    else
      patch_glimmer_container(Views.MainWindow)
    end
  end

  class ScenarioEvaluator
    include Glimmer

    def initialize(_scenario_content:)
      @_scenarios = {}

      instance_eval(_scenario_content)
    end

    # TODO: allow both "." and "/" separators
    # TODO: allow strings, symbols and Pathname
    # TODO: convert to Pathname, so Runner#scenario_for won't need to convert it's argument to string
    def scenario_for(view_path, &block)
      @_scenarios[view_path] ||= proc {}
      @_scenarios[view_path] = block << @_scenarios[view_path]
    end
  end

end