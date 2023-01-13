require 'singleton'
require 'memoized'
require 'listen'

class Glimte::Dev::Scene
  include Singleton
  include Memoized
  include Glimmer

  class SceneNotFound < StandardError; end
  class SceneNotWatched < StandardError;
    def initialize(msg = "No dev scene is watched. Use Framework::Dev::Scene.watch to start watching a scene.")
      super
    end
  end
  class SceneAlreadyWatched < StandardError; end

  class << self
    delegate :watched?, to: :instance
  end

  attr_internal_accessor :scene_path,
                         :scene_abs_path,
                         :scenarios,
                         :app_files_listener,
                         :app_files_changed

  def watch(scene_path)
    raise SceneAlreadyWatched, "Already watching #{self.scene_path}" if watched?

    # self.scene_path = ActiveFile::Utils.clean_path(scene_path).delete_suffix('.rb')
    self.scene_path = scene_path.delete_suffix('.rb')
    self.scene_abs_path = Glimte.path('dev/scenes').join("#{self.scene_path}.rb")
    raise SceneNotFound, "Can't find scene file #{scene_abs_path}" unless File.exist?(scene_abs_path)
    unmemoize :watched?

    reload
  end

  memoize def watched?
    self.scene_path.present?
  end

  def changed?
    raise SceneNotWatched unless watched?

    app_files_changed
  end

  memoize def scenario_for(view_path)
    raise SceneNotWatched unless watched?

    view_path = view_path.to_s
    scenarios[view_path].blank? ? nil : scenarios[view_path].inject(proc {}, :<<)
  end

  def reload
    raise SceneNotWatched unless watched?

    unless File.exists?(scene_abs_path)
      puts "Can't continue watching, scene file #{scene_abs_path} has been lost"
      app_files_listener&.stop
      exit 1
    end

    scene_content = File.read(scene_abs_path)
    self.scenarios = SceneEvaluator.new(_scene_content: scene_content).instance_variable_get(:@_scenarios)
    if scenarios.blank?
      puts "Warning: No scenarios found in #{scene_abs_path}. Use scenario_for to add scenarios for views."
    end

    start_app_files_listener
    unmemoize :scenario_for
    if Views.main_window_ready?
      reload_main_window
    else
      Views.MainWindow.open
    end
  end

  def patch_glimmer_container(container)
    raise SceneNotWatched unless watched?

    container.content do
      container.instance_exec(&reload_shortcut_proc)
    end
  end

  def show_render_error(error)
    raise SceneNotWatched unless watched?

    # TODO: using Views.MainWindow here causes an infinite loop - investigate why
    main_window = error.container.root_parent_proxy
    main_window.clear!
    main_window.tk.deiconify
    main_window.content do
      # make sure the message is visible
      width 1024
      height 1024 / 1.618 # why not? :)
      escapable true

      l = nil
      frame {
        padding 15
        grid row: 0, column: 0, row_weight: 1, column_weight: 1
        l = label {
          grid row: 0, column: 0, row_weight: 1, column_weight: 1, sticky: 'nw'
          wraplength main_window.width - 30
          text error.message
        }
      }

      on('Configure') do |event|
        if event.widget.is_a?(::Tk::Root) && l.tk.wraplength != event.width - 30
          l.tk.wraplength = event.width - 30
        end
      end
    end
    main_window.center_within_screen
    patch_glimmer_container(main_window)
  end

  private

  def start_app_files_listener
    app_files_listener&.stop
    self.app_files_changed = false
    # TODO: whole ./app tree?
    self.app_files_listener = Listen.to(Glimte.path('app/models'),
                                        Glimte.path('app/views')) do |modified, added, removed|
      unless app_files_changed
        puts "Notice: app files change detected, the app has to be reloaded"
        self.app_files_changed = true
      end

      puts "\"#{Time.now}\":"
      print_file_changes('modified', modified) if modified.any?
      print_file_changes('added', added) if added.any?
      print_file_changes('removed', removed) if removed.any?
    end
    app_files_listener.start
  end

  def print_file_changes(change_type, paths)
    puts "  #{change_type}"
    paths.each { |path| puts "    - #{path}"}
  end

  memoize def reload_shortcut_proc
    proc {
      on('KeyPress') { |event|
        if event.keysym.downcase == 'r' && event.state == 4
          Glimte::Dev::Scene.reload
          break false
        end
      }
      on('FocusIn') { |_|
        if Glimte::Dev::Scene.changed?
          Glimte::Dev::Scene.reload
          break false
        end
      }
    }
  end

  def reload_main_window
    Views.MainWindow.clear!

    view_abs_path = Glimte.path('app/views/main_window.glimmer.rb')
    raise Views::MainWindowTemplateNotFoundError unless File.exist?(view_abs_path)

    view_model_path = Glimte.path('app/views/main_window.rb')
    view_model_instance = ViewModels::MainWindow.new if File.exist?(view_model_path)

    begin
      Glimte::RenderView.call(_container: Views.MainWindow,
                              _view_path: 'main_window',
                              _view_model_instance: view_model_instance,
                              _body_block: scenario_for('main_window'))
    rescue Glimte::RenderView::ErrorInTemplate => e
      show_render_error(e)
    else
      patch_glimmer_container(Views.MainWindow)
    end
  end

  class SceneEvaluator
    include Glimmer

    def initialize(_scene_content:)
      @_scenarios = {}

      instance_eval(_scene_content)
    end

    def scenario_for(view_path, &block)
      @_scenarios[view_path] ||= []
      @_scenarios[view_path] << block
    end
  end

end