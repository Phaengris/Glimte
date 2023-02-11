require 'dry-initializer'

class Glimte::ViewsSelector
  extend Dry::Initializer

  param :path, default: nil, optional: true

  private

  def method_missing(name, *args, &block)
    next_path = path ? path.join(name.to_s) : Pathname.new(name.to_s)

    if File.exist?(Glimte.view_path(next_path))
      # TODO: why can't it refer to private subclasses from inside itself?
      return Glimte.const_get('CreateView').call(next_path, args, block)
    end

    if Dir.exist?(Glimte.views_path.join(next_path))
      return self.class.new(next_path)
    end

    super
  end

end

class Glimte
  private_constant :ViewsSelector
end
