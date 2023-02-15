require 'dry-initializer'
require 'facets/kernel/present'
require 'facets/string/squish'
require 'memoized'
require 'pp'

class Glimte::Utils::DebugOutput
  extend Dry::Initializer
  include Glimte::Utils::Callable
  include Memoized

  option :source
  option :message
  option :data

  module ClassMethods
    def _gli(message_or_data, data = nil)
      if message_or_data.is_a?(Hash)
        data = message_or_data
        message = nil
      else
        message = message_or_data
      end

      Glimte::Utils::DebugOutput.call(source: self, message: message, data: data)
    end
  end

  def call
=begin
DEBUG
  main_window_components.accounts_list->MyClass#my_method:99
  Something happened right here!
    key1 => "value1"
    key2 => "value2"
=end
    puts <<-DEBUG.strip
#{formatted_title}
#{formatted_header}
#{formatted_message}#{formatted_data}
DEBUG
  end

  private

  # TODO: configurable?
  def formatted_title
    Glimte::Pastel.h1 'DEBUG'
  end

  def formatted_header
    '  ' + if view_path
             Glimte::Pastel.h2(
               'Views.' +
                 view_path +
                 ':' +
                 Kernel.caller.find { |s| s.include? "(eval)" }.split(':', 3)[1]
             )
           else
             i = Kernel.caller.find_index { |s| s.include?(__FILE__) && s.include?('_gli') }
             Glimte::Pastel.h2(Kernel.caller[i + 1].delete_prefix(Glimte.root.to_s + '/'))
           end
  end

  memoize def view_path
    return if Kernel.caller.any? { |s| s.include?(":in `closest_view'") }

    view_path = case
                when source.is_a?(Glimmer::Tk::WidgetProxy)
                  source.closest_view.view_path
                # when Glimmer::DSL::Engine.parent_stack.any?
                #   Glimmer::DSL::Engine.parent_stack.last.closest_view.view_path
                else
                  return
                end
    view_path = view_path.to_s.delete_suffix('/') # TODO: fix it in ViewSelector / CreateView probably?
    view_path = 'MainWindow' if view_path == 'main_window'
    view_path
  end

  def formatted_message
    return unless message

    '  ' + Glimte::Pastel.important(message) + "\n"
  end

  def formatted_data
    if data.present?
      indent = data.keys.map(&:length).max + 4
      data.map { |k, v|
        v = v.pretty_inspect.squish.strip
        v = v[0..150] + '...' + v[-1] if v.length > 150
        ' ' * (indent - k.length) + Glimte::Pastel.data_key("#{k}:") + ' ' + Glimte::Pastel.data_value(v)
      }.join("\n")
    end
  end

  Kernel.prepend ClassMethods
end