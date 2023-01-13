require_relative './tk/treeview_selection_data_binding_expression'
require_relative './tk/glimte_expressions'

module Glimmer
  module DSL
    def self.add_expression(chain_id, expression_class)
      handler = ExpressionHandler.new(expression_class.new)
      handler.next = Engine.dynamic_expression_chains_of_responsibility[chain_id]
      Engine.dynamic_expression_chains_of_responsibility[chain_id] = handler
    end

    add_expression :tk, Tk::TreeviewSelectionDataBindingExpression
    add_expression :tk, Tk::GlimteExpressions
  end
end
