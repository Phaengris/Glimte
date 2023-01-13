require 'memoized'

module Glimte::Utils::Attr
  extend ActiveSupport::Concern

  included do |base|
    base.include Memoized
  end

  def instance_attr_reader(name, value)
    define_singleton_method name do
      value
    end
  end

  # TODO: move it out of here!!!
  def _p(*args)
    Glimte::Utils::DebugOutput.call(*args)
  end

  class_methods do

    # TODO: consider using https://dry-rb.org/gems/dry-initializer/3.0/ instead
    def init_with_attributes(*attributes)
      attr_accessor *attributes

      define_method :initialize do |*args|
        args = args.first if args.is_a?(Array) && args.one? && args.first.is_a?(Hash)

        case args
        when Hash
          args.each do |attr, val|
            raise ArgumentError, "Unexpected attribute `#{attr}`" unless attributes.include?(attr)

            send("#{attr}=", val)
          end
        when Array
          if args.count > attributes.count
            raise ArgumentError,
                  "Expected only #{attributes.count} #{"argument".pluralize(attributes.count)}, got #{args.count}"
          end

          attributes.each_with_index { |attr, i| send("#{attr}=", args[i]) }
        else
          raise ArgumentError, "Sorry, not sure how to process #{args.pretty_inspect}"
        end
      end
    end

    # TODO: any ready-to-use gem here? like https://github.com/PragTob/after_do ?
    def on_attr_write(attr, &block)
      unless instance_methods(false).include?("#{attr}=".to_sym)
        raise ArgumentError,
              "Writer for attr `#{attr}` is not defined. Use `attr_writer :#{attr}` or `attr_accessor :#{attr}` to define it."
      end
      if instance_methods(false).include?("#{attr}__skip_callback=".to_sym)
        raise ArgumentError,
              "`on_attr_write` handler for attr `#{attr}` is already defined. Multiple handlers aren't supported at the moment."
      end

      alias_method "#{attr}__skip_callback=", "#{attr}="

      define_method "#{attr}=" do |value|
        previous_value = send(attr) if respond_to?(attr)
        send("#{attr}__skip_callback=", value)
        instance_exec(value, previous_value, &block)
      end
    end
  end

end
