class Glimte::Dev::KeyCatcher
  include Glimmer
  include Glimte::Utils::Callable

  # TODO: use _p ?
  def call
    root {
      on('KeyPress') do |event|
        # TODO: add some colorization
        puts "Key event catched:\n  "\
             "char = \"#{event.char}\"\t"\
             "keycode = \"#{event.keycode}\"\t"\
             "keysym = \"#{event.keysym}\"\t"\
             "keysym_num = \"#{event.keysym_num}\"\t"\
             "state = \"#{event.state}\""
        end
    }.open
  end
end