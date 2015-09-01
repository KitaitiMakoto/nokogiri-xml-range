require 'helper'
require 'nokogiri'
require 'nokogiri/xml/range/refinement'
require 'nokogiri/xml/replacable'

class TestNokogiriXMLRangeRefinement < Test::Unit::TestCase
  using Nokogiri::XML::Range::Refinement

  def setup
    @doc = Nokogiri.XML(<<EOD)
<root>
  <parent>
    <child>child 1</child>
    <child>child 2</child>
  </parent>
</root>
EOD
    @root = @doc.root
    @parent = @root.search('parent').first
    @child1 = @parent.search('child')[0]
    @child2 = @parent.search('child')[1]
  end

  data({
    'root' => [:root, 3],
    'parent' => [:parent, 5],
    'child1' => [:child1, 1],
  })
  def test_element_length(data)
    node_name, length = data
    node = instance_variable_get("@#{node_name}")
    assert_equal length, node.length
  end

  def test_text_length
    assert_equal 7, @child1.children[0].length
  end

  def test_inclusive_ancestor?
    [@root, @parent, @child1].each do |node|
      assert_true @child1.inclusive_ancestor? node
    end
    assert_false @child1.inclusive_ancestor? @child2
  end

  def test_host_including_inclusive_ancestor?
    fragment = Nokogiri::XML::DocumentFragment.new(@doc)
    fragment.host = @parent
    child = Nokogiri::XML::Element.new('child', @doc)
    fragment << child
    assert_true child.host_including_inclusive_ancestor? @root
  end

  def test_adopt
    @doc.adopt @child1
    assert_equal @doc, @child1.document

    another_doc = Nokogiri.XML('<root><child/></root>')
    elem = another_doc.search('root').first
    @doc.adopt elem
    assert_equal @doc, elem.document
    assert_equal @doc, elem.child.document
    assert_equal Nokogiri.XML('').to_s, another_doc.to_s
  end
end
