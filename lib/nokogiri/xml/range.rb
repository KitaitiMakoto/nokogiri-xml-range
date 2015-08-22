require 'nokogiri/xml/range/version'
require 'nokogiri'

class Nokogiri::XML::Range
  class << self
    def compare_boundary_points(node1, offset1, node2, offset2)
      case node1 <=> node2
      when 0
        offset1 <=> offset2
      when 1
        compare_boundary_points(node2, offset2, node1, offset1) * -1
      else
        if node2.ancestors.include?(node1) # not need to get all ancestors
          child = node2
          children = node1.children
          until children.include? child
            child = child.parent
          end
          if children.index(child) < offset1
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
