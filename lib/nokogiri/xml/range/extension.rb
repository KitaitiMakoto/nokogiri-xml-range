module Nokogiri::XML
  class Range
    module Extension
      refine Nokogiri::XML::Node do
        def ancestors_to(node)
          nodes = []
          current = self
          root = document.root
          nodes.unshift current
          until current == node or current == root
            current = current.parent
            nodes.unshift current
          end
          return unless current == node
          nodes
        end
      end
    end
  end
end
