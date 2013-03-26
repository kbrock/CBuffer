class CBuffer
  class BufferFull < StandardError; end

  def initialize(capacity)
    @capacity = capacity+1
    clear
  end

  def get
    return if empty?
    element = @buffer[@b]
    @buffer[@b] = nil
    @b = (@b + 1) % @capacity
    element
  end

  def put(element)
    raise BufferFull if full?
    @buffer[@f] = element
    @f = (@f + 1) % @capacity
    full?
  end

  def full?
    @b == 0 ? @f == size : @f == @b-1
  end

  def empty?
    @f == @b
  end

  def size
    @capacity-1
  end

  def clear
    @buffer = Array.new(@capacity)
    @f = @b = 0
  end

  def to_s
    "<#{self.class} @size=#{size}>"
  end
end
