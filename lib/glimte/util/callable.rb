# TODO: any ready-to-use gem for that?

module Glimte::Util::Callable

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        private_class_method :new
      end
    end
  end

  module ClassMethods
    def call(*args)
      self.new(*args).call
    end
  end

end