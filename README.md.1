<!-- TOC -->
* [Glimte](#glimte)
  * [Structure of the app](#structure-of-the-app)
  * [app.rb](#apprb)
  * [Initializers](#initializers)
  * [Views](#views)
    * [app/views/main_window.glimmer.rb](#appviewsmainwindowglimmerrb)
    * [Calling views](#calling-views)
    * [View types - main window, windows, frames](#view-types---main-window-windows-frames)
    * [In subdirectories](#in-subdirectories)
    * [Includes](#includes)
  * [View models](#view-models)
    * [Calling the view model from the view](#calling-the-view-model-from-the-view)
    * [In subdirectories](#in-subdirectories-1)
    * [Initializing view model](#initializing-view-model)
  * [Forms](#forms)
  * [Glimte's additions to Glimmer](#glimtes-additions-to-glimmer)
    * [Raising Tk events](#raising-tk-events)
    * [Catching Tk events](#catching-tk-events)
    * [Modal windows](#modal-windows)
    * [Local events](#local-events)
    * [Some helper methods](#some-helper-methods)
<!-- TOC -->

# Glimte

MVVM framework based on Glimmer for creating desktop apps in Ruby / Tk

NOTE! Glimte is in the very beginning of it's way, features may not be stable, documentation may be incomplete.

References
- https://tkdocs.com/index.html
- https://github.com/AndyObtiva/glimmer
- https://github.com/AndyObtiva/glimmer-dsl-tk
- https://github.com/ruby/tk

Sample app
- https://github.com/Phaengris/PasswordStore

## Structure of the app

- app/
  - initializers/
  - views/
  - models/
  - assets/
- lib/
- dev/
  - scenarios/
  - tasks/
  - assets/
- app.rb

## app.rb

A typical `app.rb` may look like that

```ruby
#!/usr/bin/env ruby

require 'glimte'

Glimte.run
```

## Initializers

When `Glimte.run` is executed, these files are loaded before the main window is built and opened. 

The initializers are sorted alphabetically before run. So you may use `00-initializer.rb`, `01-initializer.rb`, ... to define execution order.

An initializer example 

`app/initializers/tk.rb`

```ruby
# Load a Tk theme
Tk.tk_call('source', Glimte.asset_path('tk/azure/azure.tcl'))
Tk.tk_call('set_theme', 'dark')

# Define some Tk style
Tk::Tile::Style.configure('Alert.TLabel', { "foreground" => "#FF3860" })
```

## Views

Views are described in Glimmer's declarative DSL (see references above).

Each view should be put inside `app/views/<view name>.glimmer.rb` (the `glimmer.rb` extension is mandatory for a view).

### app/views/main_window.glimmer.rb

This view must always exist, it describes the content of the Glimmer's `root` element
- https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts
- https://github.com/AndyObtiva/glimmer-dsl-tk#hello-root

```ruby
title 'My pretty simple app'

Views.shared_components.toolbar {
  grid row: 0
}

frame {
  grid row: 1, row_weight: 1
        
  label {
    text 'Hello world'
  }
  button {
    text 'Click me already'
  }
  
  Views.shared_components.statusbar {
    grid row: 2
  }
}
```

### Calling views

You can use Glimmer's widget keywords as well as references to Glimte views.
A Glimte view can be called as `Views.<path_to_view>.<view_name>` and basically shares same principles as Glimmer's keywords.

```ruby
button {
  text 'Click me!'
}

Views.special_button {
  text 'Or me!'
}

Views.funny_components.really_special_button {
  text 'Or even me!'
}
```

`Views.special_button` refers to `app/views/special_button.glimmer.rb`

`Views.funny_components.really_special_button` refers to `app/views/funny_components/really_special_button.glimmer.rb`

`Views.special_button != Views.special_button` - every time when you refer to a component, a new instance is created.

(In practice you will probably want to use views for more complex things that just implement a specific button :) In fact to customize a button you'll probably use some Tk style. An input field + a button + an error message entry = more like use case for a view.)

A special case is `Views.MainWindow` - it is the main window instance, the Glimmer's `root` component.
You always can refer to the main window as `Views.MainWindow`.
You can't call `View.main_window` to create a new main window instance.

### View types - main window, windows, frames

`Views.MainWindow` is an instance of `Glimmer::Tk::RootProxy`
- https://github.com/AndyObtiva/glimmer-dsl-tk#hello-root
- https://tkdocs.com/tutorial/windows.html

`Views.<component_name>_window` is an instance of `Glimmer::Tk::ToplevelProxy`
- https://github.com/AndyObtiva/glimmer-dsl-tk#hello-toplevel
- https://tkdocs.com/tutorial/windows.html

(note - when you call a `*_window` component, it is created inside the root element, not inside the current element)

`Views.<component_name>` is an instance of `Glimmer::Tk::FrameProxy`
- https://github.com/AndyObtiva/glimmer-dsl-tk#hello-frame
- https://tkdocs.com/tutorial/widgets.html#frame

So you can treat views as Glimmer's widgets, define `grid` for them etc

### In subdirectories

It is a Glimte convention that subdirectories refer to components united by same designation.
So it's recommended to name your directories like `<parent component or namespace>_components`. 

- app/views/
  - main_window.glimmer.rb
  - main_window_components/
    - available_entities_list.glimmer.rb
    - entity_view.glimmer.rb
    - entity_view_components/
      - entity_delete_confirmation.glimmer.rb
  - shared_components/
    - toolbar.glimmer.rb
    - statusbar.glimmer.rb

`Views.MainWindow`\
`Views.main_window_components.available_entities_list`\
`Views.main_window_components.entity_view`\
`Views.main_window_components.entity_view_components.entity_delete_confirmation`
`Views.shared_components.toolbar`\
`Views.shared_components.statusbar`

### Includes

`app/views/complex_widget.glimmer.rb`
```ruby
data_record_name
data_record_options
data_record_text_notes
```
`app/views/complex_widget_components/_data_record_name.glimmer.rb`
```ruby
entry {
  # ...
}
label {
  text <= [complex_widget.errors, :name]
  visible <= [complex_widget.errors, :name, '<=': -> (v) { !!v }]
}
```
`app/views/complex_widget_components/_data_record_options.glimmer.rb`
```ruby
# ...
```
`app/views/complex_widget_components/_data_record_text_notes.glimmer.rb`
```ruby
# ...
```

Includes (or partials) are not views. They don't have an own container, an own view model.
In fact they're just pieces of code included into the view's code. You can refer to the view's view model inside them directly (as on the example above).

## View models

`app/views/say_something.glimmer.rb`

```ruby
entry {
  variable <=> [say_something, :message]
}
button {
  text 'Say!'
  enabled <= [say_something, :message, '<=': -> (v) { !!v }]
  on('command') do
    say_something.said
  end
}
label {
  visible <= [say_something, :response]
  text <= [say_something, :response]
}
```

`app/views/say_something.rb`

```ruby
class ViewModels::SaySomething
  attr_accessor :message,
                :response
  
  def said
    self.response = "Thanks for saying \"#{message}\"!"
  end
end
```

Thanks to the Shine syntax (Glimmer's interface for dynamic data binding)
- https://github.com/AndyObtiva/glimmer#shine-data-binding-syntax
- https://github.com/AndyObtiva/glimmer-dsl-tk#data-binding

your view models are just usual Ruby objects.

You only need to define attributes (`attr_accessor`) for the view to observe and react to.

If you want to make the view model to respond to change of an attribute, you may override the corresponding `<attribute>=` method.

### Calling the view model from the view

`app/views/some_tricky_component.glimmer.rb`

```ruby
button {
  on('command') do
    some_tricky_component.do_your_job!
  end
}

# is equal to

button {
  on('command') do
    view_model.do_your_job!
  end
}
```

### In subdirectories

`app/views/pretty_components/bells_and_whistles.glimmer.rb`
`app/views/pretty_components/bells_and_whistles.rb`
```ruby
class ViewModels::PrettyComponents::BellsAndWhistles
  # ...
end
```

### Initializing view model

```ruby
class ViewModels::SaySomething
  attr_accessor :message
end
```

```ruby
Views.say_something {
  # let's propose to the user something to say by default
  message 'Ehm... hello?'
}
```

Glimmer's widget properties are the priority.
If you define `attr_accessor :grid` in your view model,
calling `grid` still will be handled by Glimmer's `grid` method,
not by yours `grid=` setter.

## Forms

Forms support is very basic at the moment. Still there are some tools available.

`app/views/form.rb`
```ruby
class ViewModels::Form
  attr_accessor :a, :b,
                :errors, :changes

  def initialize
    self.errors = Glimte::ViewModelErrors.new(:a, :b)
    
    # ... read initial values of a and b from somewhere
    
    self.changes = Glimte::ViewModelChanges(self, :a, :b)
  end
  
  def do_something
    return unless changes.a? || changes.b?
    # ...
    if we_failed?
      errors[:a] = 'Because of the value of a is invalid'
      # and / or
      errors[:b] = 'Because of the value of B is invalid'
    end
  end
end
```
`app/views/form.glimmer.rb`
```ruby
entry {
  variable <=> [form, :a]
}
label {
  visible <= [form.errors, :a]
  text <= [form.errors, :a]
}

# ... and probably some widgets for B ...

button {
  text 'Do something with A and B'
  on('command') do
    form.do_something
  end
}
```

If you use Dry::Validation https://github.com/dry-rb/dry-validation
```ruby
def do_something
  values = { a: self.a, b: self.b }
  errors.call_contract(Contract, values)
  return if errors.any?
  # ...
end

class Contract < Dry::Validation::Contract
  # ...
end
```

## Glimte's additions to Glimmer

### Raising Tk events

Using the Glimmer's `tk` property of the current widget, you can easily raise a custom Tk event
```ruby
tk.event_generate("<CustomEvent>", data: "SomeMeaningfulStringValue")
```

Glimte offers additional `raise_event` method to do it in a bit more convenient way
```ruby
raise_event 'CustomEvent', 'SomeMeaningfulStringValue'

# or even

raise_event 'CustomEvent', payload: { a: 'b', c: 'd' }
```

In the latter case, the `data` argument is converted to a YAML string.
Sorry, at the moment Glimte doesn't provide an automated YAML parsing in event handlers
(it's a TODO for the future). So you may do it like that for now:

```ruby
on('CustomEvent') do |event|
  data = YAML.load(event.data)
  # ...
end
```

### Catching Tk events

Some additions to the Glimmer's `on` method

```ruby
@another_component = Views.another_component 

on('CustomEvent', redirect_to: @another_component)

# or even

on 'Event1', 'Event2', 'Event3', redirect_to: @another_component
```

```ruby
on('CustomEvent', stop_propagation: true) do
  # ...
end

# is equal to

on('CustomEvent') do
  # ...
  break false
end
```

### Modal windows

Tk doesn't have native modal windows support. Glimte offers kind of workaround. When defining a toplevel component (a window), you can specify `modal true` property. This will do the following:
- the parent window is hidden
- the current window becomes centered inside the parent window box
- when the current window is closed, the parent window is shown again

`app/views/modal_window.glimmer.rb`
```ruby
title 'Modal window'
modal true
```

### Local events

- stay inside the view, won't bubble up to the parent widget\
(so you may not bother about name conflicts for common event names like "Action", "Cancel" etc)
- are raised directly on the view level

Good for handling local "OK" or "Cancel" etc actions

```ruby
frame {
  label {
    # describe what we do here
  }
  frame {
    # left panel with options
    # ...
    frame {
      button {
        on('command') do
          raise_event('Action', local: true)
        end
      }
      button {
        on('command') do
          raise_event('Cancel', local: true)
        end
      }
    }
  }
  frame {
    # right panel with result preview
  }
}

on('Action', local: true) do
  # perform action (or apply changes), close window
end
on('Cancel', local: true) do
  # do nothing (or discard changes), close window
end
```

```ruby
raise_action
raise_cancel
on_action do
  # ...
end
on_cancel do
  # ...
end

# are equal to

raise_event 'Action', local: true
raise_event 'Cancel', local: true
on('Action', local: true) do
  # ...
end
on('Cancel', local: true) do
  # ...
end
```

### Some helper methods

- `close_window` closes the closest window (root or toplevel). Can be called from any widget.
- `closest_view` returns the closest parent view (the current view if called on the view's level). Can be called from any widget.
- `closest_window` returns the closest parent window (root or toplevel) (the current window if called on the window's level). Can be called from any widget.
- `visible` / `hidden` pair of properties
- `enabled` / `disabled` pair of properties
