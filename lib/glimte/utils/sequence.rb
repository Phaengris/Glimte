class Glimte::Utils::Sequence

  def initialize(&block)
    @index = nil
    yield self if block_given?
  end

  def next
    return (@index = 0) if @index.nil?

    @index += 1
  end

  def with_next(&block)
    yield self.next
  end

  def current
    @index || 0
  end

end