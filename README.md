# Glimte

An MVVM framework based on Glimmer for creating desktop apps in Ruby / Tk

_TODO: support for LibUI https://github.com/AndyObtiva/glimmer-dsl-libui and may be other Glimmer-supported backends_

**Glimte is in the very beginning of it's way! Features may not be stable, documentation may be incomplete.**

References:
- https://tkdocs.com/index.html
- https://github.com/AndyObtiva/glimmer
- https://github.com/AndyObtiva/glimmer-dsl-tk
- https://github.com/ruby/tk

Sample app:
- https://github.com/Phaengris/PasswordStore

# Table of contents

<!-- TOC -->
* [Create a sample application](#create-a-sample-application)
  * [Initial setup](#initial-setup)
  * [Main window](#main-window)
  * [A brief reference](#a-brief-reference)
<!-- TOC -->

# Very simple example

## Initial setup

_TODO: implement a generator_

Pre-requisites:
- Ruby
  - Tested under Ruby 3.0. If you tried with a different version and found a problem, please [let me know](https://github.com/Phaengris/Glimte/issues/new). 
- Tk
  - For Ubuntu-based distros [this instruction](https://saveriomiroddi.github.io/Installing-ruby-tk-bindings-gem-on-ubuntu/) did the job for me 


```shell
mkdir glimte-demo
cd glimte-demo
mkdir app/views
touch app/views/main_window.glimmer.rb
echo -e "require 'glimte'\n\nGlimte.run\n" > app.rb
bundle init
bundle add glimte --git=https://github.com/Phaengris/Glimte.git
```
In the end you should have the following
```shell
$ tree
.
├── Gemfile
├── Gemfile.lock
├── app
│   └── views
│       └── main_window.glimmer.rb
└── app.rb

2 directories, 4 files

$ cat app.rb
require 'glimte'

Glimte.run
```

So now you should be able to run it

```shell
bundle exec ruby app.rb
```

And a very simple and very empty app shows up \
![image](https://user-images.githubusercontent.com/65915934/216783315-14dd2d40-b3e8-48a3-904d-37ea091ccb5b.png)

## Main window

`app/views/main_window.rb` is empty for now, so the window is also empty.

Let's add some content. Put the following code into your `main_window.glimmer.rb`

```ruby
title 'Hello world!'
escapable true

frame {
  button {
    text 'Click me'
  }
}
```
![image](https://user-images.githubusercontent.com/65915934/216783956-c8827b17-4cab-4f16-b5bf-d6c33269b98c.png) \
By the way, now you can close the window with `Escape`

Change `main_window.glimmer.rb` like the following

```ruby
title 'Hello world!'
escapable true

frame {
  label {
    text <= [view_model, :message]
  }
  button {
    text 'Click me'
    on('command') do
      view_model.count += 1
    end
  }
}
```

and create `app/views/main_window.rb` with the following code

```ruby
class ViewModels::MainWindow
  attr_accessor :count, :message

  def initialize
    self.count = 0
  end

  def count=(value)
    @count = value
    self.message = "Count = #{value}"
  end
end
```

Now, with the help of [Glimmer's data binding](https://github.com/AndyObtiva/glimmer-dsl-tk#data-binding), clicking the button changes the message\
![image](https://user-images.githubusercontent.com/65915934/216785366-2579430b-be63-43b0-a0a3-5db7a775fbb9.png)

## A brief reference

- `app/views/<component_name>.glimmer.rb`
  - describes a view in terms of the MVVM pattern
  - is written in [Glimmer's declarative syntax](https://github.com/AndyObtiva/glimmer-dsl-tk#glimmer-gui-dsl-concepts)
- `app/views/<component_name>.rb`
  - describes the view model for the `<component_name>.glimmer.rb` view
  - should define a plain simple `ViewModels::<ComponentName>` class
  - the view model instance
    - is created when the view model file exists
    - can be accessed inside the view as `view_model` or `<component_name>` (e.g. the main window model can also be accessed as `main_window`)
- `app/views/some_window.glimmer.rb`
  - the component name ends with "_window",
    that's how Glimte knows this component is a window ([root](https://github.com/Phaengris/glimmer-dsl-tk/blob/master/samples/hello/hello_root.rb) or [toplevel](https://github.com/Phaengris/glimmer-dsl-tk/blob/master/samples/hello/hello_toplevel.rb))
  - `app/views/main_window.glimmer.rb` is the root, other `_window` views are toplevels
  
# MVVM example