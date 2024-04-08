Glimte is an Ruby MVVM framework based on [Glimmer](https://github.com/AndyObtiva/glimmer)
for developing desktop applications with [Tk](https://tkdocs.com/).

**Unfortunately I'm overloaded and have no time to work on / support the project now. Feel free to fork it if you're interested. It may be resumed in the future but really can't promise atm.**

<!-- TOC -->
* [Why Tk?](#why-tk)
* [Pre-requisites](#pre-requisites)
* [Create an app](#create-an-app)
* [Views](#views)
  * [Create a view](#create-a-view)
  * [Main window](#main-window)
  * [Windows](#windows)
  * [Widgets](#widgets)
  * [Hierarchy](#hierarchy)
  * [View's instantiating](#views-instantiating)
  * [Arguments](#arguments)
  * [Fragments](#fragments)
* [View models](#view-models)
  * [Create a view model](#create-a-view-model)
  * [View model's instantiating](#view-models-instantiating)
  * [Access from the view](#access-from-the-view)
  * [Glimte::Model::Changes](#glimtemodelchanges)
  * [Glimte::Model::Errors](#glimtemodelerrors)
* [Channels](#channels)
  * [Create a channel](#create-a-channel)
  * [Send a message into the channel](#send-a-message-into-the-channel)
  * [Messages and events](#messages-and-events)
  * [For views only](#for-views-only)
* [Models](#models)
  * [Create a model](#create-a-model)
* [Initializers](#initializers)
* [Assets](#assets)
* [Development tools](#development-tools)
  * [Running in development mode](#running-in-development-mode)
  * [Development mode scenarios](#development-mode-scenarios)
  * [Console](#console)
* [Testing Glimte apps](#testing-glimte-apps)
* [Glimmer extensions](#glimmer-extensions)
  * [Treeview](#treeview)
  * [`event_generate`](#eventgenerate)
  * ["Modal" windows](#modal-windows)
  * [`center_within_screen` for Linux multi-monitor setup](#centerwithinscreen-for-linux-multi-monitor-setup)
  * [`visible` / `hidden`](#visible--hidden)
  * [`enabled` / `disabled`](#enabled--disabled)
  * [`<=` / `=>`](#--)
  * [`closest_view` / `closest_window`](#closestview--closestwindow)
  * [`close_window`](#closewindow)
* [`glimte` executable](#glimte-executable)
* [Versioning](#versioning)
* [Short term plans](#short-term-plans)
* [Long term plans](#long-term-plans)
<!-- TOC -->

(TODO: use pretty Tk theme for screenshots)

# Why Tk?

It's simple, fast and cross-platform. And it's still pretty much alive :)

Yes, the default look may be outdated, but check this out https://github.com/rdbende

also may be this post on Reddit https://www.reddit.com/r/Python/comments/lps11c/how_to_make_tkinter_look_modern_how_to_use_themes/

I was considering QT, but I found no maintained bindings for Ruby as of today.

# Pre-requisites

Ruby. Which version? For now I'm developing it under 3.0 and didn't test compatibility with other versions.
If you tried another version and it didn't work, please let me know. 

Then Tk and Ruby bindings for it \
https://github.com/AndyObtiva/glimmer-dsl-tk#pre-requisites

You may also find this useful \
https://saveriomiroddi.github.io/Installing-ruby-tk-bindings-gem-on-ubuntu/

# Create an app

Glimte is very alpha, so let's do it manually for now

(TODO: create a generator like `glimte new <app_name>`)

```shell
mkdir -p glimte-app/{app/{models,views,initializers,assets},lib,dev/{assets,scenarios}}
cd glimte-app
bundle init
bundle add glimte --git https://github.com/Phaengris/Glimte.git
```

this is what you should get

```
.
├── Gemfile
├── Gemfile.lock
├── app
│   ├── assets
│   ├── initializers
│   ├── models
│   └── views
├── dev
│   ├── assets
│   └── scenarios
└── lib
```

then create `app/views/main_window.glimmer.rb` and put some content into it, for example

```ruby
label {
  text "Hello world!"
}
```

then execute

```shell
bundle exec glimte run
```

TODO: screenshot

# Views

As Glimte is for developing desktop applications, views are the essential part of it.
In fact you can have a running application with views only, without view models / models / etc.

## Create a view

You already created an one - `app/views/main_window.glimmer.rb` is a view.

Any `*.glimmer.rb` file in `app/views/**` is a view.

Views are written using Glimmer's declarative syntax https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts

Let's extend the demo app

`app/views/main_window.glimmer.rb`
```ruby
label {
  text "Hello world!"
}
Views.some_component

```
`app/views/some_component.glimmer.rb`
```ruby
label {
  text "It's me, another view"
}
```

TODO: screenshot

## Main window

`app/views/main_window.glimmer.rb` must always exist, it describes the main window of your app.
The content of this file is what is put into the Tk root element.\
https://tkdocs.com/tutorial/concepts.html \
https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts \
https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_root.rb

_NOTE: Don't to write `root {}` in the main window view.
Just write your code, like in the examples above and the root element will be created around it.
If you put `root {}` into the main window view, Glimte will try to create a root inside a root, which is not what you want._

## Windows

It is a Glimte convention that any `app/views/**/<name>_window.glimmer.rb` view
is a Tk toplevel (that's how they're called in Tk; in other worlds they're usually called windows) \
https://tkdocs.com/tutorial/windows.html \
https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_toplevel.rb \

You can call a toplevel from any view, but in fact they're created inside the main window anyway.

```app/views/main_window.glimmer.rb```
```ruby
title "Main window"

button {
  text 'Open another window'
  on('command') do
    Views.another_window
  end
}
```

```app/views/another_window.glimmer.rb```
```ruby
title "Another window"

label {
  text 'Yes, this is another window'
}
```

TODO: screenshot

## Widgets

`app/views/**/<name>.glimmer.rb` (without the "_window" suffix in the name) is a regular view.
Under the hood it is wrapped into a Tk frame. \
https://tkdocs.com/tutorial/widgets.html#frame \
https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_frame.rb

`app/views/main_window.glimmer.rb`
```ruby
title 'Main window with widgets'

Views.first_widget
Views.second_widget
```
`app/views/first_widget.glimmer.rb`
```ruby
label {
  text 'This is the first widget'
}
```
`app/views/second_widget.glimmer.rb`
```ruby
label {
  text 'This is the second widget'
}
```

TODO: screenshot

## Hierarchy

`app/views/main_window.glimmer.rb`
```ruby
title 'Main window with widgets'

Views.main_window_components.entities_list
```
`app/views/main_window_components/entities_list.glimmer.rb`
```ruby
label {
  text 'Here could be a list of entities'
}
Views.main_window_components.entities_list_components.entity_buttons
```
`app/views/main_window_components/entities_list_components/entity_buttons.glimmer.rb`
```ruby
button {
  text 'Add'
}
button {
  text 'Remove'
}
```

TODO: screenshot

It is a Glimte convention what views which belong to a parent view are placed
into `<parent view name>_components` directory.

Views united not by a parent view, but a common designation,
may be placed in directory named after the designation.

`app/views/main_window.glimmer.rb`
```ruby
Views.shared_components.buttons.ok_cancel
```

`app/views/shared_components/buttons/ok_cancel.glimmer.rb`
```ruby
button {
  text 'OK'
}
button {
  text 'Cancel'
}
```

TODO: screenshot

## View's instantiating

A view is instantiated at the moment it is called.

Every time the view is called, a new instance is created.\
`Views.widget !== Views.widget`


`app/views/main_window.glimmer.rb`
```ruby
Views.widget
Views.widget
```
`app/views/widget.glimmer.rb`
```ruby
label {
  text rand.to_s
}
```

TODO: screenshot

The main window is an exception. It is created right when the application starts. \
`Views.MainWindow === Views.MainWindow` \
`Views.main_window` triggers an error - a new instance of the main window can't be created.

## Arguments

As views are defined using Glimmer DSL, they can be configured the same way.\
The arguments are specific per the view's container

- which is `frame` for regular views \
  https://tkdocs.com/tutorial/widgets.html#frame \
  https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_frame.rb
- and `toplevel` for windows \
  https://tkdocs.com/tutorial/windows.html \
  https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_toplevel.rb \

and can be specified inside curved brackets, just like for any Glimmer / Tk widget.

`app/views/main_window.glimmer.rb`
```ruby
Views.widget {
  grid row: 0, column: 0
  
  on('WidgetButtonClicked') do
    puts 'Widget button clicked'
  end
}
```
`app/views/widget.glimmer.rb`
```ruby
padding 20

button {
  text 'Click me'
  
  on('command') do
    tk.event_generate('WidgetButtonClicked')
  end
}
```

Which arguments / event handlers to put into the view call and which into the view body?
- Good arguments for the view call:
  - Which define view's placement inside the parent view
  - Event handlers which define view's behavior relative to the parent view
- Good arguments for the view body:
  - Which define view's internal placement not dependent on it's parent
  - Event handlers which define view's internal behavior

## Fragments

Sometimes your view's code may be too long to fit into a single file.
Then you can split it into fragments.

Fragments are put into `<view name>_components` directory, just like child views.
But their names start with an underscore.
Fragments are available to the parent view only and can be called by their names without the underscore.

`app/views/main_window.glimmer.rb`
```ruby
some_description
various_controls
ok_cancel_buttons
```
`app/views/main_window_components/_some_description.glimmer.rb`
```ruby
label {
  text 'Some description of what\'s going on here'
}
```
`app/views/main_window_components/_various_controls.glimmer.rb`
```ruby
checkbutton {
  text 'Do this'
}
checkbutton {
  text 'Do that'
}
```
`app/views/main_window_components/_ok_cancel_buttons.glimmer.rb`
```ruby
button {
  text 'OK'
}
button {
  text 'Cancel'
}
```

TODO: screenshot

How fragments are different from views?

- Fragments are available to the parent view only
- Fragments aren't available through `Views` namespace
- Fragments can only be called as methods available inside of the parent view
- Fragments don't have a separate view model, instead they use the parent view's view model
  - `view_model` inside of a fragment is the same as `view_model` inside of the parent view
- Arguments can't be passed to fragments

In other words, fragments are kind of a syntax sugar for something like `load __dir__ + '/_<fragment_name>.glimmer.rb'`.

# View models

As Glimte as an MVVM framework, view models are also the essential part of it.

View models are Ruby classes which are responsible for the view's logic.

Technically you can build a primitive app without a single view model, but when you click a button,
you probably want to happen something more than just a click animation.

`app/views/main_window.glimmer.rb`
```ruby
@data = Struct.new(:a, :b, :sum).new

entry {
  text <=> [@data, :a]
}
entry {
  text <=> [@data, :b]
}
button {
  text 'Calculate'
  
  on('command') do
    @data.sum = @data.a + @data.b
  end
}
label {
  text <=> [@data, :sum]
}
```

TODO: screenshot

We may consider `@data` as a primitive view model.

It's connected with the corresponding widgets through Glimmer Shine bindings
- https://github.com/AndyObtiva/glimmer#shine-data-binding-syntax
- https://github.com/AndyObtiva/glimmer-dsl-tk#data-binding 

A quick review of Shine syntax:
- `text <=> [@data, :a]` means
  - when `@data.a` changes, the widget's `text` property is updated
  - when the widget's `text` property changes, `@data.a` is updated
- `<=` and `=>` works on the same principle, but only one way

## Create a view model

It's, of course, not a good idea to put the view model into the view. Let's do in a Glimte way.

`app/views/main_window.glimmer.rb`
```ruby
entry {
  text <=> [view_model, :a]
}
entry {
  text <=> [view_model, :b]
}
button {
  text 'Calculate'
  
  on('command') do
    view_model.calculate_sum
  end
}
label {
  text <=> [view_model, :sum]
}
```
`app/views/main_window.rb`
```ruby
class ViewModels::MainWindow
  attr_accessor :a, :b, :sum
  
  def calculate_sum
    self.sum = a + b
  end
end
```

It is a Glimte convention that the view model is placed next to the view.
The difference is that the view model's file name ends with `.rb`.
This way Glimte knows there's a view model for this view and can load it automatically.

It is a Glimte convention that all view model classes are put into `ViewModels` namespace.
This way we can differentiate view models from models and other classes.
For example, you may have a `User` model, then you create a view for it `app/views/user.glimmer.rb` and a view model for that view `app/views/user.rb` / `ViewModels::User`.

The naming convention is simple: `ViewModels::<CamelCased view name>`
- app/views/main_window.glimmer.rb => ViewModels::MainWindow
- app/views/main_window_components/main_window.glimmer.rb => ViewModels::MainWindowComponents::MainWindow

A view model class is a plain Ruby class in fact. There are no requirements about how to implement it.
But you may want to use `attr_accessor` for all the properties which are bound to the view, because of Glimmer / Shine works this way.

## View model's instantiating

The view model is created right at the moment the view is created.

When another instance of a view is created (remember that every view instance is standalone),
it'll provided with a standalone view model instance.

## Access from the view

There are two methods to interact with the view model:
- `view_model` method
- `<view name>` method

This code
`app/views/main_window.glimmer.rb`
```ruby
button {
  text 'Calculate'
  
  on('command') do
    view_model.calculate_sum
  end
}
```
is equivalent to this code
```ruby
button {
  text 'Calculate'
  
  on('command') do
    main_window.calculate_sum
  end
}
```
In case of a nested path, the `<view name>` method is still based on the base name of the view, without it's path components.
For example, the view model of `app/views/main_window_components/widget.glimmer.rb` is referred to as `widget`, not as something like `main_window_components_widget`.

There's no way for a view to access another view's view model.
Glimte supposes that the view model describes the logic of a single view only.
Of course, you can create an instance of a view model class, but that'd be a single instance not bound to any view.

There's no way for a view model to access the view.
Glimte supposes that the view model implements internally some logic, which is used by the view through the view model's methods / properties. 

## Glimte::Model::Changes

TODO: to be described

## Glimte::Model::Errors

TODO: to be described

# Channels

Channels are a way to communicate between views. They may be considered as an extended version of events.

TODO: explain why not native Tk events. (In short - they're suitable for Tk needs, but not so much for passing more or less complex data.)

`app/views/main_window.glimmer.rb`
```ruby
Views.main_window_components.representation
Views.main_window_components.controls
```
`app/views/main_window_components/representation.glimmer.rb`
```ruby
label {
  text <=> [representation, :text]
}
Channels.main_window_components.text_changed do |event|
  representation.text = event[:text]
end
```
`app/views/main_window_components/representation.rb`
```ruby
class ViewModels::MainWindowComponents::Representation
  attr_accessor :text
end
```
`app/views/main_window_components/controls.glimmer.rb`
```ruby
entry {
  on('Change') do |event|
    Channels.main_window_components.text_changed(text: event.data)
  end
}
```

TODO: screenshot

In this simple example we organize communication between two views.

Can we do same with Tk events? Yes, we can.
- Views.main_window_components.controls catches `Change` event on the entry widget
- the handler of the event generates a custom Tk event '<TextChanged>'
- the event bubbles up to Views.MainWindow
- Views.MainWindow should catch the event and pass it down to Views.main_window_components.representation somehow

Too complicated even for a simple example. For sure a headache for more complex communication.

## Create a channel

The view which is interested in the channel should declare it.

```ruby
Channels.channel_name.feature_name do |event|
  # do something with the event
end
```

Channel names can be nested, like
```ruby
Channels.some_components.more_and_more_things.call_me do |event|
  # ...
end
```

## Send a message into the channel

```ruby
Channels.channel_name.feature_name(data: 'some data')
```

## Messages and events

Depends on when and how they're defined / called, channels can be used as messages or events.

If I'm a view and I want:
- something to be done - I send a message
- notify everyone that's something happened - I raise an event

If I'm a view and I can:
- do something - I define a message handler
- react to something - I define an event handler

The difference is pure semantic and is more like about code style.
There's no technical difference, but you should keep in mind the following:

- A message handler is defined in the widget which provides the feature,
  while another widgets can send messages which this widgets can handle.

- An event is raised in the widget where something can happen,
  while another widgets can define event handlers which will be called when the event is raised.

The Glimte convention is to name events in passive voice, like `text_changed`,
while messages are named in imperative voice, like `change_text`.

`app/views/widget_one.glimmer.rb`
```ruby
# we handle a message and other widgets can send it with Channels.widget_one.change_text
Channels.widget_one.change_text do |event|
  text = event[:text]
  # do something with the text
end

# we handle an event and widget_two can raise it with Channels.widget_two.text_changed
Channels.widget_two.text_changed do |event|
  text = event[:text]
  # do something with the text
end
```

`app/views/widget_two.glimmer.rb`
```ruby
# the result is the same, but communication is organized differently   
Channels.widget_one.change_text(text: 'Hello, world!')
Channels.widget_two.text_changed(text: 'Hello, world!')
```

## For views only

Channels are meant for communication between views only.
The idea is what happens between views shouldn't affect their view models directly.

And while the view model is meant to define the logic of a single view,
it'd not be logical to give it access to channels which could affect other views.

# Models

A model is any class placed under app/models.

`app/models/data.rb`
```ruby
class Data
  # @return [Data | nil]
  def self.find_by_id(id)
    # ...
  end
end
```
`app/view_models/data_widget.rb`
```ruby
class ViewModels::DataWidget
  attr_accessor :data_id, :data_value
  
  def data_id=(id)
    @data_id = id
    @data_value = Data.find_by_id(id)&.value
  end
end
```
`app/views/data_widget.glimmer.rb`
```ruby
label {
  text <=> [data_widget, :data_id]
  visible <= [data_widget, :data_value]
}
label {
  text 'No matching record found'
  hidden <= [data_widget, :data_value]
}
entry {
  on('Change') do |event|
    data_widget.data_id = event.data
  end
}
```

Why not use a model directly in the view?

- A model can be complicated enough, it may provide a lot of methods, including destructive ones,
  which you may not want to expose to the view directly.
- The view could require data from several models and it may be a mess to organize them all in the view.

So that's what the MVVM pattern is about and that's why we don't use models in views:

- The model or models provide data,
- the view model organizes it the way that's convenient for the view
- and the view uses it.

## Create a model

Glimte uses [Zeitwerk](https://github.com/fxn/zeitwerk), so you just need to place your
models under `app/models` and name them correspondingly to their path:
- `app/models/data.rb` -> `Data`
- `app/models/data/record.rb` -> `Data::Record`

Then you can call them in your views by their class name and Zeitwerk will load them automatically.

There are no specific technical requirements for the internal organization of the model.
 
# Initializers

Initializers are meant to prepare the ground before launching the app.

They are placed under `app/initializers` and are loaded in alphabetical order.

When initializers are called, the application is already booted, but not launched yet.
So `Glimte.<helper>` methods are available already, like `Glimte.path` etc.

`app/initializers/01_tk_theme.rb`
```ruby
# load the main theme
Tk.tk_call('source', Glimte.asset_path('tk/azure/azure.tcl'))
Tk.tk_call('set_theme', 'dark')
# define some styles
Tk::Tile::Style.configure('Success.TLabel', { "background" => "#23D160", foreground: "#FFFFFF" })
Tk::Tile::Style.configure('Alert.TLable', { "background" => "#FF3860", foreground: "#FFFFFF" })
```

# Assets

Assets are resource files your application needs to run - Tk stylesheets, images, etc.

Place them under app/assets.

Refer to them using `Glimte.asset_path` helper.

- If you app is placed under `/home/ruby_developer/applications/glimte_app`,
- and you place an asset into `app/assets/tk/azure/azure.tcl`,
- then `Glimte.asset_path('tk/azure/azure.tcl')` will return
"/home/ruby_developer/applications/glimte_app/app/assets/tk/azure/azure.tcl"

`app/assets/icons/icon.png`

TODO: icon image

`app/views/main_window.glimmer.rb`
```ruby
button {
  image Glimte.asset_path('icons/icon.png')
}
```

TODO: screenshot

# Development tools

## Running in development mode

When you develop a Glimte app and you do some changes in your code,
the app has to be reloaded in order these changes to take effect.

Glimte provides a tool to do it automatically.

When you run `glimte run -d|--dev`, Glimte starts to track changes in models / view models / views.
When it detects a change, it remembers that the app has to be reloaded.
Next time you focus the app window, Glimte will reload the app.

You also have the hotkey `Ctrl+R` to reload the app manually.

TODO: make the hotkey configurable

## Development mode scenarios

When the app is reloaded in development mode, it brings you back to the main window.

Which is not always what you want, especially if you are working on some situation
which requires to perform some actions to reproduce.

That's why Glimte supports development scenarios.

`dev/scenarios/edit_data_record.rb`
```ruby
scenario_for('main_window') do
  Views.data_components.edit {
    data_id 1
  }
end
```
`bundle exec glimte run --dev --scenario edit_data_record`

This way Glimte will execute the scenario and bring you to the `edit_data_record` window
every time the app is reloaded.

The block is executed in context of the view, after the view is fully initialized.
So all the view elements and the view model are available.

`scenario_for` expects a view path as an argument. It can be nested, of course.

`dev/scenarios/search.rb`
```ruby
scenario_for('main_window_components.search_entry') do
  search_entry.text = 'some text'
  # or view_model.text = 'some text'
end
```

## Console

Glimte provides a console to interact with the app.

`bundle exec glimte c|console`

It is useful mostly for playing with models / view models / included libraries.
Not so much for views, because of if you start a view,
Tk main loop will take over the current process.

# Testing Glimte apps

TODO: to be described

# Glimmer extensions

Glimte provides some extensions to Glimmer DSL.

Some of them are proposed to be merged into Glimmer itself.
- https://github.com/AndyObtiva/glimmer-dsl-tk/pull/14

## Treeview

TODO: to be described

## `event_generate`

A "smart" version of Tk's `event_generate` method.

```ruby
button {
  command do
    event_generate('MyEvent', a: 1, b: 2)
  end
}
```

Being provided with non-string arguments, it will convert them to a YAML string.

Unfortunately at the moment there's no automatic conversion back
in the event handlers (Glimmer's `on` method). It's a TODO.

## "Modal" windows

Tk support kind of modal windows with [Tk's `grab` method](https://tkdocs.com/tutorial/windows.html).
This method block interaction with the parent window
until the toplevel which "grabbed" the input releases it.

Still how it's implemented in Tk, it allows to switch to the parent window
or any other toplevels if there are any (despite of all their controls are blocked),
minimize the toplevel which "grabbed" the input. So there's a possibility for the user
to lose the context of the modal window which we want the user to stay in.

That's why Glimte provides a `modal` option for toplevels. If this option is set to `true`,
the toplevel
- grabs the input,
- hides the main window,
- when the user closes the toplevel (or it closes itself),
  it releases the input and shows the main window again.

`app/views/main_window.glimmer.rb`
```ruby
Views.dialog_window
```
`app/views/dialog_window.glimmer.rb`
```ruby
modal true
title 'Dialog Window'
label {
  text 'Hello from Dialog Window'
}
```

That's why "modal", not modal - because of that's not a true modal,
but some kind of workaround. See the discussion in the PR: https://github.com/AndyObtiva/glimmer-dsl-tk/pull/14#discussion_r1125726951

TODO: screenshots with modal = false and modal = true

## `center_within_screen` for Linux multi-monitor setup

`center_within_screen` is a useful Glimmer method for windows which centers the window on the screen
Unfortunately for multi-monitor Linux setups Tk considers all the monitors as one big screen.
So `center_within_screen` centers the toplevel on the whole virtual screen, not on the current monitor.

Glimte provides a patch which tries to use `xrandr` output to determine the current monitor
and place the window on the center of it.

This patch is very experimental and may not work in all cases.

## `visible` / `hidden`

These widget properties can be used to set the visibility of the widget.
In conjunction with Shine they can be used to dynamically show / hide widgets.

```ruby
label {
  text 'Hello'
  visible <=> [view_model, :visible]
}
button {
  text 'Toggle'
  command do
    view_model.visible = !view_model.visible
  end
}
```

`hidden` can be used same way as `visible`, but with the opposite effect.

It's probably a good idea not to use them together in the same widget driven by the same property.

## `enabled` / `disabled`

These widget properties can be used to set if the widget can be interacted with.
Again, they better work in conjunction with Shine.

```ruby
entry {
  text <=> [view_model, :text]
  enabled <=> [view_model, :enabled]
}
button {
  text 'Toggle'
  command do
    view_model.enabled = !view_model.enabled
  end
}
```

The same notes as for `hidden` are applicable for `disabled`.

## `<=` / `=>`

## `closest_view` / `closest_window`

## `close_window`

# `glimte` executable

# Versioning

Glimte is very alpha. The API is not stable, some ideas behind Glimte
are still being explored.

Until Glimte is more or less shaped, I plan to use versioning like `0.0.x`.

After that I plan to release `0.1.0` and follow [semver](https://semver.org/).

Also since `0.1.0` Glimte will be released as a gem.

# Short term plans

- Write tests :)
- Create a sample app
- Cover the code with RDoc

# Long term plans

- Support [LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui) and may be other Glimmer-covered backends

