class CBuffer
  class BufferFull < StandardError; end

  def initialize(capacity)
    @capacity = capacity+1
    clear
  end

  def get(everything=false)
    if everything || ! empty?
      element = @buffer[@b]
      @buffer[@b] = nil
      @b = (@b + 1) % @capacity
      element
    end
  end

  def put(element)
    @buffer[@f] = element
    @f = (@f + 1) % @capacity
    #ran out of capacity, throw away the extra node
    get(true) if @f == @b
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
