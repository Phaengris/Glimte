module Glimmer_Override
  def self.prepended(base)
    base.class_eval do
      class << self
        prepend ::Glimmer_Override::ClassMethods
      end
    end
  end

  module ClassMethods
    def included(base)
      base.class_eval <<-DEF
        module Views
          private def self.method_missing(name, *args, &block)
            ::Glimte.instance.views.send(name, *args, &block)
          end
        end
        module Channels
          private def self.method_missing(name, *args, &block)
            ::Glimte.instance.channels.send(name, *args, &block)
          end
        end
      DEF
      super
    end
  end

  ::Glimmer.prepend self
end
