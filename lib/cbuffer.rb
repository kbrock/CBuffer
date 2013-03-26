class CBuffer
  def initialize(capacity)
    @capacity = capacity+1
    clear
  end

  def put(element)
    @buffer[@f] = element
    @f = (@f + 1) % @capacity
    #ran out of capacity, throw away the extra node
    pop if @f == @b
  end

  #start at the most recent, and scan backtwards until we found the record of interest
  def scan(&block)
    raise "no block given" unless block_given?
    if @f == @b
      [nil,[]]
    elsif @f > @b
      simple_scan(@f-1, @b, &block)
    else
      misses=[]
      ret=simple_scan(@f-1, 0, misses, &block)
      if ret.first
        ret
      else
        simple_scan(@capacity-1, @b, misses, &block)
      end
    end
  end

  def get
    pop unless empty?
  end

  def all
    if @f == @b
      []
    elsif @f > @b
      @buffer[@b...@f]
    else
      @buffer[@b...@capacity] + @buffer[0...@f]
    end
  end

  def empty?
    @f == @b
  end

  def clear
    @buffer = Array.new(@capacity)
    @f = @b = 0
  end

  def to_s
    "<#{self.class} @size=#{size}>"
  end

  private
  def simple_scan(top,bottom,misses=[],&block)
    i=top #-1
    while(i>=bottom)
      cur=@buffer[i]
      if yield(cur)
        return [cur, misses]
      else
        misses << cur
        i-=1
      end
    end
    [nil, misses]
  end

  def pop
    element = @buffer[@b]
    @buffer[@b] = nil
    @b = (@b + 1) % @capacity
    element
  end
end
