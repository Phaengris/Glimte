module Views
  class MainWindowTemplateNotFoundError < StandardError
    def initialize(msg = 'app/views/main_window.glimmer.rb must exist')
      super
    end
  end
  class MainWindowAsComponentError < StandardError; end

  def self.MainWindow
    @main_window ||= begin
                       unless File.file?(Glimte.path('app/views/main_window.glimmer.rb'))
                         raise MainWindowTemplateNotFoundError
                       end
                       Glimte::CreateView.call(Pathname.new('main_window'))
                     end
    @main_window
  end

  def self.main_window
    raise MainWindowAsComponentError, "You can't create a main window component. Use Views.MainWindow to call the main window instance."
  end

  def self.main_window_ready?
    @main_window.present?
  end

  def self.method_missing(name, *args, &block)
    Glimte::ViewsSelector.new.send(name, *args, &block)
  end

end
