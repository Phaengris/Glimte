require 'memoized'
require 'yaml'

module Glimmer_Tk_WidgetProxy_Override
  include Memoized

  def view?
    respond_to?(:view_path)
  end

  def window?
    is_a?(Glimmer::Tk::ToplevelProxy) || is_a?(Glimmer::Tk::RootProxy)
  end

  def closest_view
    widget = self
    widget = widget.parent_proxy until widget.view?
    widget
  end

  def closest_window
    widget = self
    widget = widget.parent_proxy until widget.window?
    widget
  end

  def raise_event(event_name, data_or_options = nil, options_or_data = {})
    data, options =
      case
      when data_or_options&.is_a?(String)
        [data_or_options, options_or_data]
      when data_or_options&.is_a?(Hash) && options_or_data.empty?
        [(data_or_options.delete(:data) if data_or_options.key?(:data)), data_or_options]
      else
        [data_or_options, options_or_data]
      end

    data = YAML.dump(data) unless data&.is_a?(String)
    event_name = local_event_name(event_name) if options[:local]

    tk.event_generate("<#{event_name}>", data: data)
  end

  def action
    closest_view.raise_event 'Action', local: true
  end

  def cancel
    closest_view.raise_event 'Cancel', local: true
  end

  def on(*args, &listener)
    options = (args.pop if args.last&.is_a?(Hash)) || {}
    if args.many?
      args.each do |listener_name|
        on(*[listener_name, options], &listener)
      end
      return
    else
      listener_name = args.first
    end

    if options[:local] && !view?
      # TODO: better exception?
      raise 'Local view events can only be caught on the top level of a view, not in a particular component'
    end

    if options[:redirect_to]
      raise ArgumentError, "Can't use `redirect_to` and handling block together" if block_given?
      listener = redirect_event_proc(listener_name, options)
    end

    if options[:redirected] || options[:stop_propagation]
      _listener = listener
      listener = proc { |event| _listener.call(event); break false }
    end

    listener = keep_current_context_proc(&listener)

    listener_name = 'command' if listener_name == 'Command'

    if options[:local]
      super local_listener_name(listener_name), &listener
    else
      super listener_name, &listener
    end
  end

  def on_action(&listener)
    # TODO: better exception?
    raise 'This handler can be defined only on the top level of a view' unless view?

    on('Action', local: true, &listener)
  end

  def on_cancel(&listener)
    # TODO: better exception?
    raise 'This handler can be defined only on the top level of a view' unless view?

    on('Cancel', local: true, &listener)
  end

  def grid(options = {})
    index_in_parent = griddable_parent_proxy&.children&.index(griddable_proxy)
    row_uniform     = options.delete(:row_uniform)
    column_uniform  = options.delete(:column_uniform)
    if index_in_parent
      case
      when row_uniform
        TkGrid.rowconfigure(griddable_parent_proxy.tk, index_in_parent, 'uniform' => row_uniform)
      when column_uniform
        TkGrid.columnconfigure(griddable_parent_proxy.tk, index_in_parent, 'uniform' => column_uniform)
      end
    end
    @_visible = true
    super
  end

  def visible
    instance_variable_defined?(:@_visible) ? @_visible : (@_visible = true)
  end
  alias_method :visible?, :visible

  def visible=(value)
    value = !!value
    return if visible == value

    if value
      grid
    else
      tk.grid_remove
    end
    @_visible = value
  end

  def hidden
    !visible
  end
  alias_method :hidden?, :hidden

  def hidden=(value)
    self.visible = !value
  end

  def enabled
    tk.state == 'normal'
  end
  alias_method :enabled?, :enabled

  def enabled=(value)
    tk.state = !!value ? 'normal' : 'disabled'
  end

  def disabled
    !enabled
  end
  alias_method :disabled?, :disabled

  def disabled=(value)
    self.enabled = !value
  end

  def style=(style_name_or_styles)
    if style_name_or_styles.is_a? String
      @tk.style(style_name_or_styles)
    else
      super
    end
  end

  def destroy
    children.each(&:destroy)
    super
  end

  def unbind_all
    @listeners&.keys&.each do |key|
      if key.to_s.downcase.include?('command')
        @tk.send(key, '')
      else
        @tk.bind_remove(key)
      end
    end
    @listeners = nil
  end

  def clear!
    unbind_all
    children.each(&:destroy)
    @children = []
  end

  # TODO: fix it in Glimmer
  # https://github.com/AndyObtiva/glimmer-dsl-tk/blob/v0.0.62/lib/glimmer/tk/toplevel_proxy.rb#L43
  def grab_release
    @tk.grab_release
  end

  def close_window
    closest_window.destroy
  end

  private

  # this way we prevent local Action / Cancel events to cause problems if they're not caught and bubble up
  # TODO: any better way to do that?

  memoize def local_listener_name(listener_name)
    "#{local_listener_name_prefix}_#{listener_name}"
  end
  alias_method :local_event_name, :local_listener_name

  memoize def local_listener_name_prefix
    "#{self.closest_view.view_path.to_s.split('/').map { |part| part.camelcase(true) }.join('_')}_#{SecureRandom.hex(4)}"
  end

  def redirect_event_proc(listener_name, listener_options)
    target = listener_options[:redirect_to]

    if listener_options[:local]
      proc do |event|
        widget = target.is_a?(Proc) ? target.call(event) : target
        widget.raise_event(listener_name, event.detail, local: true)
        break false
      end

    else
      proc do |event|
        @redirected_events ||= {}
        if @redirected_events[listener_name]&.include?(event.widget)
          raise RuntimeError, "Event #{listener_name} was redirected to #{event.widget}, but bubbled up again. "\
                              "Use `redirected: true` or `stop_propagation: true` or just `break false` to prevent that."
        end

        widget = target.is_a?(Proc) ? target.call(event) : target

        @redirected_events[listener_name] ||= []
        @redirected_events[listener_name] << widget.tk

        widget.raise_event(listener_name, event.detail)
        break false
      end

    end
  end

  # after the template is evaluated, the dsl / parent stacks are cleared
  # when we execute the event handler block, expressions fail because they can't find their dsl / parent anymore
  # TODO: any better way to solve this? avoiding using system-wide stack for single local operation?
  def keep_current_context_proc(&listener)
    dsl = Glimmer::DSL::Engine.dsl_stack.last
    parent = Glimmer::DSL::Engine.parent_stack.last

    proc do |event|
      Glimmer::DSL::Engine.dsl_stack.push(dsl) unless Glimmer::DSL::Engine.dsl_stack.last == dsl
      Glimmer::DSL::Engine.parent_stack.push(parent) unless Glimmer::DSL::Engine.parent_stack.last == parent
      listener.call(event)
      Glimmer::DSL::Engine.parent_stack.pop if Glimmer::DSL::Engine.parent_stack.last == parent
      Glimmer::DSL::Engine.dsl_stack.pop if Glimmer::DSL::Engine.dsl_stack.last == dsl
    end
  end

  ::Glimmer::Tk::WidgetProxy.prepend self
end
