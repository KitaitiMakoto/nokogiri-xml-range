module Nokogiri::XML
  class Range
    module Refinement
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

        def inclusive_ancestors
          [self] + ancestors
        end

        def inclusive_ancestor?(node)
          inclusive_ancestors.include? node
        end

        def host_including_inclusive_ancestor?(node)
          return true if inclusive_ancestor? node
          root_node = ancestors.first
          root_node.fragment? and
            root_node.host.host_including_inclusive_ancestor?(node)
        end

        def replacable?
          kind_of? Nokogiri::XML::Replacable
        end
      end

      refine DocumentFragment do
        attr_accessor :host
      end
    end
  end
end
