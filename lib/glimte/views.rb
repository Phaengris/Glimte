class Glimte::Views
  class MainWindowTemplateNotFoundError < StandardError; end
  class MainWindowAsComponentError < StandardError; end

  def MainWindow
    @main_window ||= begin
                       unless File.file?(Glimte.view_path('main_window'))
                         raise MainWindowTemplateNotFoundError, "#{Glimte.view_path('main_window')} must exist"
                       end
                       Glimte::CreateView.call(Pathname.new('main_window'))
                     end
    @main_window
  end

  def main_window
    raise MainWindowAsComponentError, "You can't create a main window component. Use Views.MainWindow to call the main window instance."
  end

  def main_window_ready?
    @main_window.present?
  end

  private

  def method_missing(name, *args, &block)
    Glimte::ViewsSelector.new.send(name, *args, &block)
  end
end

class Glimte
  private_constant :Views
end
