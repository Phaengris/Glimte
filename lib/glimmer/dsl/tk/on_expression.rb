module Glimmer_DSL_Tk_OnExpression
  def interpret(parent, keyword, *args, &block)
    parent.on(*args, &block)
  end

  Glimmer::DSL::Tk::OnExpression.prepend self
end