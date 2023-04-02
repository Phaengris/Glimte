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
    * [Instantiating](#instantiating)
    * [Arguments](#arguments)
<!-- TOC -->

(use pretty Tk theme for screenshots)

## Why Tk?

It's simple, fast and cross-platform. And it's still pretty much alive :)

Yes, the default look may be outdated, but check this out https://github.com/rdbende

also may be this post on Reddit https://www.reddit.com/r/Python/comments/lps11c/how_to_make_tkinter_look_modern_how_to_use_themes/

I was considering QT, but I found no maintained bindings for Ruby as of today

## Pre-requisites

Ruby. Which version? For now I develop under 3.0 and didn't test compatibility with other versions.

Then Tk and Ruby bindings for it \
https://github.com/AndyObtiva/glimmer-dsl-tk#pre-requisites

You may also find this useful \
https://saveriomiroddi.github.io/Installing-ruby-tk-bindings-gem-on-ubuntu/

## Create an app

Glimte is very alpha, so let's do it manually for now

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

and execute

```shell
bundle exec glimte run
```

TODO: screenshot

## Views

As Glimte is for developing desktop applications, views are the essential part of it.
In fact you can have a running application with views only, without view models / models / etc.

### Create a view

You already created an one - yes, `app/views/main_window.glimmer.rb` is a view.

Any `.glimmer.rb` file in `app/views` or any subdirectory of it is a view.

Views should be written using Glimmer's declarative syntax https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts

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

And remember to execute
```shell
bundle exec glimte run
```
_(I won't specifically write it anymore in the examples below, just please remember to do it :)_

TODO: screenshot

### Main window

`app/views/main_window.glimmer.rb` must always exist and it describes the main window of your app.
In fact the content of this file is what is put into the Tk root element.\
https://tkdocs.com/tutorial/concepts.html \
https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts \
https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_root.rb

_Note: you don't have to write `root {}` in the main window view.
Just write your code and the root element will be created around it, just like in the examples above.
If you write `root {}`, it'll be a root inside a root, which is not what you want :)_

### Windows 

`app/views/**/some_window.glimmer.rb` is a Tk toplevel (that's how they're called in Tk; in other worlds they're usually called windows)
https://tkdocs.com/tutorial/windows.html \
https://github.com/AndyObtiva/glimmer-dsl-tk/blob/master/samples/hello/hello_toplevel.rb \

It is a Glimte convention that any `*_window.glimmer.rb` view becomes a toplevel.
You can call it from any view, but in fact they're created inside the main window anyway.

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

### Widgets

app/views/**/some_view.glimmer.rb is a regular view.
Under the hood it is a Tk frame. \
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

### Hierarchy

`app/views/main_window.glimmer.rb`
```ruby
title 'Main window with widgets'

Views.main_window_components.second_level_widget
```
`app/views/main_window_components/second_level_widget.glimmer.rb`
```ruby
label {
  text 'A second level widget of the main window components'
}
Views.main_window_components.second_level_widget_components.third_level_widget
```
`app/views/main_window_components/second_level_widget_components/third_level_widget.glimmer.rb`
```ruby
label {
  text 'A third level widget of the second level widget components'
}
```

TODO: screenshot

It is a Glimte convention what views which belong to a parent view are placed
into `<parent view name>_components` directory.

Views united not by a parent view, but a common designation,
may be placed in directory named after the designation.
For example, `shared_components`, `shared_components/buttons`
so the widget can be called as `Views.shared_components.buttons.ok_cancel` etc.

### Instantiating

A view is instantiated at the moment it is called.

`Views.some_widget !== Views.some_widget`. \
Every time a view is called, a new instance is created.

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

### Arguments

As views are defined using Glimmer DSL, they can be managed the same way.
Their container-specific arguments (`frame` for widgets, `toplevel` for windows)
can be specified inside curved brackets, just like for any Glimmer / Tk widget.

```ruby
Views.some_widget {
  grid row: 1, column: 1
  
  on('CustomEvent') do
    # ...
  end
}
```

Which arguments are worth it to be put inside 

- Views
  - *.glimmer.rb
  - MainWindow
  - Views.component_name / app/views/component_name.glimmer.rb
  - Views.components.component_name / app/views/components/component_name.glimmer.rb
  - _partial_name / components/_partial_name.glimmer.rb
- View models
  - ViewModels::ComponentName / app/views/component_name.rb for app/views/component_name.glimmer.rb
  - ViewModels::Components::ComponentName, Zeitwerk
  - auto instantiating, independence from other views, view_model / component_name
  - interaction with the view model through accessors / Glimmer Shine bindings
  - Glimte::Model::Changes
  - Glimte::Model::Errors
  - action / on_action, cancel / on_cancel
- Channels
  - why not Tk events 
  - defining Channels.channel_name.feature_name do |event| ... end
  - calling Channels.channel_name.feature_name args
  - events / requests semantic difference
- Models
  - app/models, Zeitwerk
  - relations with view models
- Initializers
  - app/initializers
  - examples for Tk themes / styles
- Assets
  - app/assets
  - examples for Tk themes / styles
  - examples for images
- Dev
  - assets
  - scenarios (a brief description, with referring to the chapter below)
- Testing (TODO: think what to write here)
- Glimmer extensions
  - (ref to PR)
  - Treeview (describe data structure)
  - raise_event
  - modal = true
  - center_within_screen for Linux multi-monitor setup
  - center_within_root
  - visible / hidden
  - enabled / disabled
  - '<=', '=>'
  - closest_view
  - closest_window
  - close_window
- `glimte` binary
  - run
    - --dev
    - --scenario, dev/scenarios
  - console
- Versioning
  - current (< 0.1.0)
  - future (>= 0.1.0) semver
- Short term plans
  - Tests! (as soon as API is more or less stable)
  - RDoc!
- Long term plans
  - support LibUI and may be other Glimmer-covered backends