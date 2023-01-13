class Glimte::ViewsSelector
  include Glimte::Utils::Attr

  init_with_attributes :path

  def method_missing(name, *args, &block)
    next_path = path ? Pathname.new(path).join(name.to_s) : Pathname.new(name.to_s)

    if File.exist?(Glimte.path("app/views/#{next_path}.glimmer.rb"))
      return Glimte::CreateView.call(next_path, args, block)
    end

    if Dir.exist?(Glimte.path("app/views/#{next_path}"))
      return self.class.new(next_path)
    end

    super
  end

end