require 'helper'

# https://github.com/bbcrd/CBuffer
# Original author Duncan Robertson <duncan.robertson at bbc.co.uk>
# Modifications Keenan Brock <keenan@thebrocks.net>
class TestCBuffer < Test::Unit::TestCase
  def test_simple
    b = CBuffer.new(7)
    assert b.empty?
    b.put "one"
    b.put "two"
    b.put "three"
    assert_equal "one", b.get
    b.put "four"
    assert_equal "two", b.get
    b.put "five"
    b.put "six"
    b.put "seven"
    assert_equal "three", b.get
    b.put "eight"
    b.put "nine"
    b.put nil 
    assert_equal "four", b.get
    assert_equal "five", b.get
    assert_equal "six", b.get
    assert_equal "seven", b.get
    assert_equal "eight", b.get
    assert_equal "nine", b.get
    assert_equal nil, b.get
  end

  def test_circularness
    b = CBuffer.new(5)
    b.put 1                 # [1,_,_,_,_,x]
    b.put 2                 # [1,2,_,_,_,x]
    b.put 3                 # [1,2,3,_,_,x]
    assert_equal 1, b.get   # [x,2,3,_,_,_]
    b.put 4                 # [x,2,3,4,_,_]
    b.put 5                 # [x,2,3,4,5,_]
    b.put 6                 # [6,x,2,3,4,5]
    #cause overflow
    b.put 7                 # [6,7,x,3,4,5]
    assert_equal 3, b.get   # [6,7,_,x,4,5]
    b.put 8                 # [6,7,8,x,4,5]
    #cause overflow
    b.put 9                 # [6,7,8,9,x,5]
    assert_equal 5, b.get   # [6,7,8,9,_,x]
  end

  def test_buffer_overload
    b = CBuffer.new(3)
      b.put(1)
      b.put(2)
      b.put(3)
      b.put(4) #overflow
      assert_equal 2, b.get
  end

  def test_buffer_overload_with_nil
    b = CBuffer.new(3)
      b.put 1
      b.put 2
      b.put 3
      b.put nil #overflow
      assert_equal 2, b.get
  end
  
  def test_clear_buffer
    b = CBuffer.new(3)
    b.put(1)
    b.put(2)
    b.put(8)
    b.put(9)
    b.clear
    assert b.empty?
    assert_nil b.get
  end

  def test_example_used_in_readme
    b = CBuffer.new(4)
    b.put({ :item => "one" })
    b.put({ :item => "two" })
    b.put({ :item => "three" })
    assert_equal({:item => "one"}, b.get)
    assert_equal({:item => "two"}, b.get)
    b.put(nil)
    b.put({ :item => "four" })
    assert_equal({:item => "three"}, b.get)
    assert_equal(nil, b.get)
    assert_equal({ :item => "four" }, b.get)
  end

  def test_again
    b = CBuffer.new(5)
    assert ! b.put(1)
    assert ! b.put(2)
    assert ! b.put(3)
    assert ! b.put(4)
    assert ! b.put(5) #nothing dropped yet
    assert_equal 1, b.get
    assert_equal 2, b.get
    assert_equal 3, b.get
    assert_equal 4, b.get
    assert_equal 5, b.get
    assert_equal nil, b.get
    assert_equal nil, b.get
    assert !b.put(1)
    assert !b.put(2)
    assert !b.put(3)
    assert !b.put(4)
    assert_equal 1, b.get
    assert_equal 2, b.get
    assert_equal 3, b.get
    assert_equal 4, b.get
  end

  def test_all
    b = CBuffer.new(5)
    assert_equal [], b.all
    b.put 1                 # [1,_,_,_,_,x]
    b.put 2                 # [1,2,_,_,_,x]
    b.put 3                 # [1,2,3,_,_,x]
    b.put 4                 # [1,2,3,4,_,x]
    b.put 5                 # [1,2,3,4,5,x]
    assert_equal (1..5).to_a, b.all
    b.put 6                 # [x,2,3,4,5,6]
    b.put 7                 # [6,7,x,3,4,5]
    assert_equal (3..7).to_a, b.all
    b.put 8                 # [6,7,8,x,4,5]
    b.put 9                 # [6,7,8,9,x,5]
    assert_equal (5..9).to_a, b.all
    b.clear
    assert_equal [], b.all
  end

  def test_empty_scan
    b = tb(5)
    assert_equal([nil,[]], b.scan {|i| i == 4 })
  end

  def test_simple_scan_first
    b = tb(5,4)
    assert_equal([4,[]], b.scan {|i| i == 4 })
  end

  def test_simple_scan_mid
    b = tb(5,4)
    assert_equal([2,[4,3]], b.scan {|i| i == 2 })
  end

  def test_simple_scan_last
    b = tb(5,4)
    assert_equal([1,[4,3,2]], b.scan {|i| i == 1 })
  end

  def test_simple_scan_not_found
    b = tb(5,4)
    assert_equal([nil,[4,3,2,1]], b.scan {|i| i == 0 })
  end

  def test_complex_scan_first
    b = tb(5,7) # 7,6|5,4,3
    assert_equal([7,[]], b.scan {|i| i == 7 })
  end

  def test_complex_scan_mid
    b = tb(5,7) # 7,6|5,4,3
    assert_equal([4,[7,6,5]], b.scan {|i| i == 4 })
  end

  def test_complex_scan_last
    b = tb(5,7) # 7,6|5,4,3
    assert_equal([3,[7,6,5,4]], b.scan {|i| i == 3 })
  end

  def test_complex_scan_not_found
    b = tb(5,7) # 7,6|5,4,3
    assert_equal([nil,[7,6,5,4,3]], b.scan {|i| i == 2 })
  end

  private

  def tb(cap, num=nil)
    b = CBuffer.new(cap)
    (1..num).each {|i| b.put i } if num
    b
  end
end
