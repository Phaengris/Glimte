# in fact it could be used to track changes in any instance of any class, so
# TODO: name it AttributeChangesObserver or smth like that?

class Glimte::ViewModelChanges
  class AttributeNotChanged < StandardError; end

  attr_internal_accessor :original_values, :changed_values

  def initialize(model, *attrs)
    self.original_values = {}
    self.changed_values = {}

    attrs.each do |attr|
      observe model, attr
    end
  end

  private

  def observe(model, attr)
    self.original_values[attr] = model.send(attr)

    observer = Glimmer::DataBinding::Observer.proc do |value|
      if original_values[attr] == value
        self.changed_values.delete(attr) if changed_values.key?(attr)
      else
        self.changed_values[attr] = value
      end
    end
    observer.observe model, attr

    define_singleton_method "#{attr}?" do
      original_values[attr] != changed_values[attr]
    end

    define_singleton_method "#{attr}_original" do
      original_values[attr]
    end

    define_singleton_method "#{attr}_changed" do
      changed_values[attr] || raise(AttributeNotChanged)
    end
  end

end