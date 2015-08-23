module Nokogiri::XML
  class Range
    module Extension
      refine Node do
        def ancestors_to(node)
          nodes = NodeSet.new(document)
          current = self
          root = document.root
          nodes << current
          until current == node or current == root
            current = current.parent
            nodes << current
          end
          return unless current == node
          nodes
        end

        def length
          case type
          when Node::DOCUMENT_TYPE_NODE
            0
          when Node::TEXT_NODE, Node::CDATA_SECTION_NODE, Node::PI_NODE, Node::COMMENT_NODE
            content.encode('UTF-16LE').bytesize / 2
          else
            children.length
          end
        end
      end
    end
  end
end
