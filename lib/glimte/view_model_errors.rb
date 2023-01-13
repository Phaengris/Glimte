require 'ostruct'

class Glimte::ViewModelErrors < OpenStruct
  attr_internal_accessor :keys

  def initialize(keys)
    keys = Array(keys).map(&:to_sym)

    if (forbidden_keys = keys & self.class.instance_methods(false)).any?
      raise ArgumentError, <<-MSG.squish.strip
          Can't use #{forbidden_keys.map { |key| "\"#{key}\"" }
                                    .to_sentence(two_words_connector: 'or', last_word_connector: 'or')}
          as #{forbidden_keys.one? ? 'a key' : 'keys'}
      MSG
    end

    self.keys = keys

    super keys.map { |key| [key, nil] }.to_h
  end

  def any?
    self.keys.each { |key| return true if self.send(key).present? }
    false
  end

  def none?
    !any?
  end

  def call_contract(contract_class, values_to_validate)
    contract_errors = contract_class.new.call(values_to_validate).errors.to_h
    self.keys.each { |key| self.send("#{key}=", contract_errors[key]&.to_sentence&.capitalize) }
  end
end
