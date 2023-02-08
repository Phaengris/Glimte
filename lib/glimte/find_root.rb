class Glimte::FindRoot
  include Glimte::Util::Callable

  def call
    return Dir.pwd if glimte_dir?(Dir.pwd)

    if (app_rb_line = caller.find { |line| line.match /\/app\.rb:/ }) &&
      glimte_dir?((app_rb_dir = app_rb_line.split('/app.rb:')))

      return app_rb_dir
    end

    nil
  end

  private

  def glimte_dir?(path)
    File.file?("#{path}/app.rb") && File.file?("#{path}/app/views/main_window.glimmer.rb")
  end
end

class Glimte
  private_constant :FindRoot
end
