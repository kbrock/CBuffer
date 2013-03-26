require 'helper'

# https://github.com/bbcrd/CBuffer
# Original author Duncan Robertson <duncan.robertson at bbc.co.uk>
# Modifications Keenan Brock <keenan@thebrocks.net>
class TestCBuffer < Test::Unit::TestCase
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

  def test_complex_scan_not_found
    b = tb(5,7) # 7,6|5,4,3
    b.clear
    assert_equal([nil,[]], b.scan {|i| i == 2 })
  end

  private

  def tb(cap, num=nil)
    b = CBuffer.new(cap)
    (1..num).each {|i| b.put i } if num
    b
  end
end
