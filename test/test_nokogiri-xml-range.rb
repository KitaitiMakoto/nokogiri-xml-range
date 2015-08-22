require 'helper'
require 'nokogiri/xml/range'

class TestNokogiriXMLRange < Test::Unit::TestCase
  def test_version
    version = Nokogiri::XML::Range.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

  def test_compare_points
    doc = Nokogiri.XML('<root><child>child 1</child><child>child 2</child></root>')
    children = doc.search('child')
    child1 = children[0]
    child2 = children[1]

    assert_equal -1, Nokogiri::XML::Range.compare_points(child1, 0, child1, 1)
    assert_equal 1, Nokogiri::XML::Range.compare_points(child2, 0, child1, 0)
    assert_equal 0, Nokogiri::XML::Range.compare_points(child1, 1, child1, 1)
    assert_equal -1, Nokogiri::XML::Range.compare_points(doc.root, 0, child1, 0)
    assert_equal 1, Nokogiri::XML::Range.compare_points(doc.root, 2, child1, 1)
    assert_equal -1, Nokogiri::XML::Range.compare_points(child1, 0, child2, 3)
  end

  def test_contain?
    doc = Nokogiri.XML(<<EOX)
<root>
  <child>child 1</child>
  <child>child 2</child>
</root>
EOX
    child1 = doc.search('child')[0]
    child2 = doc.search('child')[1]

    assert_true Nokogiri::XML::Range.new(doc.root, 0, child2, 0).contain?(child1)
    assert_false Nokogiri::XML::Range.new(doc.root, 0, child1, 1).contain?(child2)
  end
end
