require 'nokogiri/xml/range/version'
require 'nokogiri'
require 'nokogiri/xml/range/extension'

using Nokogiri::XML::Range::Extension

class Nokogiri::XML::Range
  class << self
    def compare_points(node1, offset1, node2, offset2)
      return unless node1.document == node2.document

      case node1 <=> node2
      when 0
        offset1 <=> offset2
      when 1
        compare_points(node2, offset2, node1, offset1) * -1
      else
        ancestors = node2.ancestors_to(node1) # nil or [node1, child of node1, ..., parent of node2, node2]
        if ancestors
          if node1.children.index(ancestors[1]) < offset1
            1
          else
            -1
          end
        else
          -1
        end
      end
    end
  end
end
