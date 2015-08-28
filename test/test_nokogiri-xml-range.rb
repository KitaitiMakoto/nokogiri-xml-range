# coding: utf-8
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

  def test_set_start_before
    range = Nokogiri::XML::Range.new(@child2, 0, @child2, 1)
    range.set_start_before(@child1)

    assert_equal [@parent, 1], range.start_point
  end

  def test_set_start_after
    range = Nokogiri::XML::Range.new(@child2, 0, @child2, 1)
    range.set_start_after(@child1)

    assert_equal [@parent, 2], range.start_point
  end

  def test_set_end_before
    range = Nokogiri::XML::Range.new(@child1, 0, @child2, 1)
    range.set_end_before(@parent)

    assert_equal [@root, 1], range.end_point
  end

  def test_set_end_after
    range = Nokogiri::XML::Range.new(@child1, 0, @child2, 1)
    range.set_end_after(@parent)

    assert_equal [@root, 2], range.end_point
  end

  def test_collapse
    range = Nokogiri::XML::Range.new(@child1, 0, @child2, 1)
    range.collapse!

    assert_equal [@child2, 1], range.start_point
    assert_equal [@child2, 1], range.end_point
  end

  def test_select_node
    range = Nokogiri::XML::Range.new(@child1, 0, @child2, 1)
    range.select_node(@parent)

    assert_equal [@root, 1], range.start_point
    assert_equal [@root, 2], range.end_point
  end

  def test_select_node_contents
    range = Nokogiri::XML::Range.new(@child1, 0, @child2, 1)
    range.select_node_contents @child2

    assert_equal [@child2, 0], range.start_point
    assert_equal [@child2, 1], range.end_point
  end

  data(
    {
      'START_TO_START' => [-1, Nokogiri::XML::Range::START_TO_START],
      'START_TO_END' => [1, Nokogiri::XML::Range::START_TO_END],
      'END_TO_END' => [1, Nokogiri::XML::Range::END_TO_END],
      'END_TO_START' => [-1, Nokogiri::XML::Range::END_TO_START]
    }
  )
  def test_compare_boundary_points(data)
    comparison, how = data

    range1 = Nokogiri::XML::Range.new(@parent, 0, @child2, 1)
    range2 = Nokogiri::XML::Range.new(@child1, 0, @parent, 3)

    assert_equal comparison, range1.compare_boundary_points(how, range2)
  end

  def test_delete_contents_child_elements
    range = Nokogiri::XML::Range.new(@child1, 0, @parent, 4)
    range.delete_contents

    assert_equal Nokogiri.XML(<<EXPECTED).to_s, @doc.to_s
<root>
  <parent>
    <child/>
  </parent>
</root>
EXPECTED
  end

  def test_delete_contents_text
    range = Nokogiri::XML::Range.new(@child1.children[0], 1, @child1.children[0], 5)
    range.delete_contents

    assert_equal Nokogiri.XML(<<EXPECTED).to_s, @doc.to_s
<root>
  <parent>
    <child>c 1</child>
    <child>child 2</child>
  </parent>
</root>
EXPECTED
  end

  def test_extract_contents_child_elements
    range = Nokogiri::XML::Range.new(@child1, 0, @parent, 4)
    range.extract_contents

    assert_equal Nokogiri.XML(<<EXPECTED).to_s, @doc.to_s
<root>
  <parent>
    <child/>
  </parent>
</root>
EXPECTED
  end

  def test_extract_contents_text
    range = Nokogiri::XML::Range.new(@child1.children[0], 1, @child1.children[0], 5)
    range.extract_contents

    assert_equal Nokogiri.XML(<<EXPECTED).to_s, @doc.to_s
<root>
  <parent>
    <child>c 1</child>
    <child>child 2</child>
  </parent>
</root>
EXPECTED
  end

  def test_extract_contents_from_elements
    range = Nokogiri::XML::Range.new(@child1.child, 1, @child2.child, 5)
    extracted = range.extract_contents

    assert_equal Nokogiri.XML(<<REMAINED).to_s, @doc.to_s
<root>
  <parent>
    <child>c</child><child> 2</child>
  </parent>
</root>
REMAINED
    assert_equal <<EXTRACTED.chomp, extracted.to_s.chomp
<child>hild 1</child>
    <child>child</child>
EXTRACTED
  end

  def test_extract_contents_from_text
    range = Nokogiri::XML::Range.new(@child1.child, 1, @child1.child, 5)
    extracted = range.extract_contents

    assert_equal Nokogiri.XML(<<REMAINED).to_s, @doc.to_s
<root>
  <parent>
    <child>c 1</child>
    <child>child 2</child>
  </parent>
</root>
REMAINED
    assert_equal 'hild', extracted.to_s
  end
end
