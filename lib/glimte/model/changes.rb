class Glimte::Model::Changes
  class AttributeNotChanged < StandardError; end

  def initialize(model, *attrs)
    @original_values = {}
    @changed_values = {}

    attrs.each do |attr|
      observe model, attr
    end
  end

  private

  def observe(model, attr)
    @original_values[attr] = model.send(attr)

    observer = Glimmer::DataBinding::Observer.proc do |value|
      if @original_values[attr] == value
        @changed_values.delete(attr) if @changed_values.key?(attr)
      else
        @changed_values[attr] = value
      end
    end
    observer.observe model, attr

    define_singleton_method "#{attr}?" do
      @original_values[attr] != @changed_values[attr]
    end

    define_singleton_method "#{attr}_changed?" do
      @original_values[attr] != @changed_values[attr]
    end

    define_singleton_method "#{attr}_original" do
      @original_values[attr]
    end

    define_singleton_method "#{attr}_changed" do
      @changed_values[attr] || raise(AttributeNotChanged)
    end
  end

end