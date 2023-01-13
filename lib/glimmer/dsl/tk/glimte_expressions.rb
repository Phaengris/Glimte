require 'glimmer/dsl/expression'
require 'memoized'

class Glimmer::DSL::Tk::GlimteExpressions < Glimmer::DSL::Expression
  include Memoized
  # TODO: Draft: let's keep it simple for now, split to separate expressions later
  # TODO: some of these may be offered for Glimmer itself?

  KEYWORDS = %w[on_action on_cancel close_window].map(&:freeze).freeze

  def can_interpret?(parent, keyword, *args, &block)
    # unmemoize :view_model_setter_available?
    keyword.in?(KEYWORDS) || view_model_setter_available?(parent, keyword)
  end

  def interpret(parent, keyword, *args, &block)
    case
    when keyword.in?(KEYWORDS)
      parent.send(keyword, *args, &block)
    when view_model_setter_available?(parent, keyword)
      parent.view_model.send("#{keyword}=", *args)
    else
      raise 'You shouldn\'t be here'
    end
  end

  private

  memoize def view_model_setter_available?(parent, keyword)
    parent.view? &&
      parent.view_model &&
      (parent.view_model.public_methods - parent.public_methods).include?("#{keyword}=".to_sym)
  end

end