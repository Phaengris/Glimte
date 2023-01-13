# TODO: any ready-to-use gem for that?

module Glimte::Utils::Callable
  extend ActiveSupport::Concern

  included do |base|
    base.class_eval do
      class << self
        private_class_method :new
      end
    end
  end

  class_methods do
    def call(*args)
      self.new(*args).call
    end
  end

end