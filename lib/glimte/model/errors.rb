require 'ostruct'
require 'facets/array/conjoin'

class Glimte::Model::Errors < OpenStruct
  def initialize(keys)
    @keys = Array(keys).map(&:to_sym)

    if (forbidden_keys = @keys & self.class.instance_methods(false)).any?
      raise ArgumentError, <<-MSG.squish.strip
          Can't use #{forbidden_keys.map { |key| "\"#{key}\"" }.conjoin(', ', last: ' or ')}
          as #{forbidden_keys.one? ? 'a key' : 'keys'}
      MSG
    end

    super @keys.map { |key| [key, nil] }.to_h
  end

  def any?
    @keys.each { |key| return true if self.send(key).present? }
    false
  end

  def none?
    !any?
  end

  def call_contract(contract_class, values_to_validate)
    contract_errors = contract_class.new.call(values_to_validate).errors.to_h
    @keys.each { |key| self.send("#{key}=", contract_errors[key]&.conjoin(', ', last: ' and ')&.capitalize) }
  end
end
