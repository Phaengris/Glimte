require 'memoized'

module Glimte::ViewHelpers
  include Memoized

  class PlacementConflict < StandardError; end

  memoize def rows
    raise PlacementConflict, 'Components placement is already defined as columns' if @_columns_initialized
    @_rows_initialized = true
    Glimte::Util::Sequence.new
  end

  memoize def columns
    raise PlacementConflict, 'Components placement is already defined as rows' if @_rows_initialized
    @_columns_initialized = true
    Glimte::Util::Sequence.new
  end

  def rows_separator(size = 15)
    frame { grid row: rows.next, pady: [0, size] }
  end

  def columns_separator(size = 15)
    frame { grid column: columns.next, padx: [0, size] }
  end

end