module Glimmer_DataBinding_ModelBinding_Override
  def initialize(*args)
    if (binding_options = args.last)&.is_a?(Hash)

      if binding_options.key?(:'<=')
        # TODO: binding_options.key?(:on_read) doesn't work here (returns true) - why?
        raise ArgumentError, 'Can\'t use :on_read and it\'s alias :<= together' if binding_options[:on_read]
        binding_options[:on_read] = binding_options.delete(:'<=')
      end

      if binding_options.key?(:'=>')
        raise ArgumentError, 'Can\'t use :on_write and it\'s alias :=> together' if binding_options[:on_write]
        binding_options[:on_write] = binding_options.delete(:'=>')
      end

    end
    super
  end

  Glimmer::DataBinding::ModelBinding.prepend self
end
