require 'pastel'

module Glimte::Pastel
  def self.default(s)
    pastel.white(s)
  end

  def self.h1(s)
    pastel.bright_cyan(s)
  end

  def self.h2(s)
    pastel.bright_white(s)
  end

  def self.data_key(s)
    pastel.bright_blue(s)
  end

  class << self
    alias_method :data_value, :default
  end

  def self.important(s)
    pastel.bright_yellow(s)
  end

  private

  def self.pastel
    @pastel ||= Pastel.new
  end
end