require 'dry-initializer'
require 'omnes/bus'

=begin
# Define channels

Channels.flash_message.success do |event|
  ...
end
Channels.flash_message.alert do |event|
  ...
end

TODO: or / and?
Channels.flash_message do |channel|
  channel.success do |event|
    ...
  end
  channel.alert do |event|
    ...
  end
end

# Sending request / event through a channel

Channels.flash_message.success message: '...'

# Difference between a channel request and a channel event is semantic

Channels.search_string.update do |event|
  # a request
  search_string.text = event[:value]
end

Channels.search_string.update 'new value'

Channels.search_string.updated do |event|
  # an event
  puts "Search string value is now #{event.payload[:value]}"
end

Channels.search_string.updated 'new value'
=end

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
      args = args.first if args.is_a?(Array) && args.one?
      self.class.bus.publish(event_name, **args)
    end

    self.class.new(next_path)
  end

end

class Glimte
  private_constant :ChannelsSelector
end
