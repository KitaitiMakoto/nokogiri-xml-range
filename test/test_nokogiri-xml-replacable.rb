require 'helper'
require 'nokogiri'
require 'nokogiri/xml/range/refinement'

class TestNokogiriXMLReplacable < Test::Unit::TestCase
  using Nokogiri::XML::Range::Refinement

  def setup
    @doc = Nokogiri::XML::Document.new
    @text = Nokogiri::XML::Text.new('Hello, world.', @doc)
  end

  def test_substring_data
    assert_equal 'Hello, world.', @text.substring_data(0, 9999)
    assert_equal 'world', @text.substring_data(7, 5)
  end

  def test_replace_data
    @text.replace_data 7, 5, 'Nokogiri'
    assert_equal 'Hello, Nokogiri.', @text.content
  end
end
