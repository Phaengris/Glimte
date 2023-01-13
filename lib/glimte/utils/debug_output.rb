require 'pastel'

class Glimte::Utils::DebugOutput
  include Glimte::Utils::Attr
  include Glimte::Utils::Callable

  init_with_attributes :msg, :data

  def call

  end

  # def _debug(msg_or_data = nil, data = {})
  #   # return unless Framework::Dev::Scene.watched?
  #
  #   if msg_or_data.is_a?(Hash)
  #     msg = nil
  #     data = msg_or_data
  #   else
  #     msg = msg_or_data
  #   end
  #
  #   header = 'DEBUG'
  #   class_name = self.class.to_s
  #   method_name_separator = self.is_a?(Class) ? '.' : '#'
  #   method_name = Kernel.caller.first.match(/in `([^']+)'/)[1]
  #   # view_path = if method_name == 'closest_view'
  #   #               nil
  #   #             elsif self.is_a?(Glimmer::Tk::WidgetProxy)
  #   #               self.closest_view.view_path
  #   #             elsif Glimmer::DSL::Engine.parent_stack.any?
  #   #               Glimmer::DSL::Engine.parent_stack.last.closest_view.view_path
  #   #             end
  #   formatted_data = if data.any?
  #                      data.map { |k, v|
  #                        v = v.inspect
  #                        v = v[0..150] + '...' + v[-1] if v.length > 150
  #                        [k, v]
  #                      }.to_h
  #                    end
  #
  #   pastel = Pastel.new
  #   header = pastel.bright_cyan(header)
  #   class_name = pastel.white(class_name)
  #   method_name_separator = pastel.white(method_name_separator)
  #   method_name = pastel.bright_white(method_name)
  #   # if view_path
  #   #   view_path = '  ' + pastel.cyan(view_path + '->')
  #   # else
  #   class_name = '  ' + class_name
  #   # end
  #   msg = '  ' + pastel.bright_yellow(msg) + "\n" if msg
  #   formatted_data = if formatted_data
  #                      indent = formatted_data.keys.map(&:length).max + 4
  #                      formatted_data.map { |k, v|
  #                        ' ' * (indent - k.length) + pastel.bright_blue("- #{k}: ") + pastel.white(v)
  #                      }.join("\n")
  #                    end
  #
  #   # puts "#{header}\n#{view_path}#{class_name}#{method_name_separator}#{method_name}\n#{msg}#{formatted_data}"
  #   puts "#{header}\n#{class_name}#{method_name_separator}#{method_name}\n#{msg}#{formatted_data}"
  # end
end