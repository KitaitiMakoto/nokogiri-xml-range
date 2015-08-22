require 'helper'
require 'nokogiri/xml/range'

class TestNokogiri::XML::Range < Test::Unit::TestCase

  def test_version
    version = Nokogiri::XML::Range.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

end
