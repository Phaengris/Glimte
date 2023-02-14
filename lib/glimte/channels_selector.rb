require 'dry-initializer'
require 'omnes/bus'

class Glimte::ChannelsSelector
  extend Dry::Initializer

  def self.bus
    @bus ||= Omnes::Bus.new
  end

  param :path, default: nil, optional: true

  private

  def method_missing(name, *args, &block)
    next_path = path ? path.join(name.to_s) : Pathname.new(name.to_s)
    event_name = next_path.to_s.to_sym

    if block_given?
      self.class.bus.register(event_name) unless self.class.bus.registry.registered?(event_name)
      self.class.bus.subscribe(event_name, &block)
      return
    end

    if self.class.bus.registry.registered?(event_name)
      self.class.bus.publish(event_name, *args)
    end

    self.class.new(next_path)
  end

end

class Glimte
  private_constant :ChannelsSelector
end
