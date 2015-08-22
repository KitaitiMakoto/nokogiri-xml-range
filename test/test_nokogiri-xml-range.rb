require 'helper'
require 'nokogiri/xml/range'

class TestNokogiriXMLRange < Test::Unit::TestCase
  def setup
    @doc = Nokogiri.XML(<<EOX)
<root>
  <parent>
    <child>child 1</child>
    <child>child 2</child>
  </parent>
</root>
EOX
    @root = @doc.search('root')[0]
    @parent = @doc.search('parent')[0]
    @child1 = @doc.search('child')[0]
    @child2 = @doc.search('child')[1]
  end

  def test_version
    version = Nokogiri::XML::Range.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

  def test_compare_points
    assert_equal -1, Nokogiri::XML::Range.compare_points(@child1, 0, @child1, 1)
    assert_equal 1, Nokogiri::XML::Range.compare_points(@child2, 0, @child1, 0)
    assert_equal 0, Nokogiri::XML::Range.compare_points(@child1, 1, @child1, 1)
    assert_equal -1, Nokogiri::XML::Range.compare_points(@doc.root, 0, @child1, 0)
    assert_equal 1, Nokogiri::XML::Range.compare_points(@doc.root, 2, @child1, 1)
    assert_equal -1, Nokogiri::XML::Range.compare_points(@child1, 0, @child2, 3)
  end

  def test_contain_node?
    assert_true Nokogiri::XML::Range.new(@doc.root, 0, @child2, 0).contain_node?(@child1)
    assert_false Nokogiri::XML::Range.new(@doc.root, 0, @child1, 1).contain_node?(@child2)
  end

  def test_partially_contain_node?
    assert_false Nokogiri::XML::Range.new(@root, 0, @child1, 0).partially_contain_node?(@child2)
    assert_false Nokogiri::XML::Range.new(@child1, 0, @child2, 0).partially_contain_node?(@root)
    assert_false Nokogiri::XML::Range.new(@child1, 0, @child1, 1).partially_contain_node?(@child2)
    assert_true Nokogiri::XML::Range.new(@child1.children[0], 0, @child2, 0).partially_contain_node?(@child1)
  end

  def test_common_ancestor_container
    assert_equal @parent, Nokogiri::XML::Range.new(@child1, 0, @child2.children[0], 0).common_ancestor_container
  end

  def test_set_boundary_point
    range1 = Nokogiri::XML::Range.new(@child1, 0, @child2, 0)
    range2 = range1.dup

    range1.set_start @parent, 1
    assert_equal [@parent, 1], range1.start_point

    range2.set_end @parent, 1
    assert_equal [@parent, 1], range2.end_point
    assert_equal [@parent, 1], range2.start_point
  end
end
