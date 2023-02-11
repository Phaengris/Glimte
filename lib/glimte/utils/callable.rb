# TODO: any ready-to-use gem for that?

module Glimte::Utils::Callable

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        private_class_method :new
      end
    end
  end

  module ClassMethods
    def call(*args, **more_args)
      if args.present?
        self.new(*args).call
      elsif more_args.present?
        self.new(**more_args).call
      else
        self.new.call
      end
    end
  end

end