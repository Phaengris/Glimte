class Glimte::Dev::KeyCatcher
  include Glimmer
  include Glimte::Utils::Callable

  # TODO: use _p ?
  def call
    root {
      on('KeyPress') { |event|
        puts "Key event catched:\n  "\
             "char = \"#{event.char}\"\t"\
             "keycode = \"#{event.keycode}\"\t"\
             "keysym = \"#{event.keysym}\"\t"\
             "keysym_num = \"#{event.keysym_num}\"\t"\
             "state = \"#{event.state}\""
      }
    }.open
  end
end