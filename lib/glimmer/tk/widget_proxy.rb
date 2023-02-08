module Glimmer_Tk_WidgetProxy_Override
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

  def on(listener_name, &listener)
    listener = keep_current_context_proc(&listener)
    listener_name = 'command' if listener_name == 'Command'

    super listener_name, &listener
  end

  # def action
  #   closest_view.raise_event 'Action', local: true
  # end

  # def cancel
  #   closest_view.raise_event 'Cancel', local: true
  # end

  # def on_action(&listener)
  #   # TODO: better exception?
  #   raise 'This handler can be defined only on the top level of a view' unless view?
  #
  #   on('Action', local: true, &listener)
  # end

  # def on_cancel(&listener)
  #   # TODO: better exception?
  #   raise 'This handler can be defined only on the top level of a view' unless view?
  #
  #   on('Cancel', local: true, &listener)
  # end

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
