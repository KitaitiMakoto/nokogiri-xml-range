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

        def following_node
          child || next_sibling
        end

        def preceding_node
          previous_sibling || parent
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

        def validate_pre_insertion(parent, child)
          unless [Node::DOCUMENT_TYPE_NODE, Node::DOCUMENT_FRAG_NODE, Node::ELEMENT_NODE].include? parent.type
            raise HierarchyRequestError
          end
          raise HierarchyRequestError if parent.host_including_inclusive_ancestor? self
          raise NotFoundError if child and child.parent != parent
          unless [Node::DOCUMENT_FRAG_NODE, Node::DOCUMENT_TYPE_NODE, Node::ELEMENT_NODE, Node::TEXT_NODE, Node::PI_NODE, Node::COMMENT_NODE].include? type
            raise HierarchyRequestError
          end
          raise HierarchyRequestError if text? && document?
          raise HierarchyRequestError if type == Node::DOCUMENT_TYPE_NODE and !parent.document?
          return unless parent.document?
          case type
          when Node::DOCUMENT_FRAG_NODE
            child_element_count = 0
            children.each do |node|
              raise HierarchyRequestError if node.text?
              child_element_count += 1 if node.element?
              raise HierarchyRequestError if child_element_count > 1
            end
            if child_element_count == 1
              raise HierarchyRequestError if parent.children.any?(&:element?)
              return unless child
              raise HierarchyRequestError if child.type = Node::DOCUMENT_TYPE_NODE
              raise HierarchyRequestError if child.following_node.type == Node::DOCUMENT_TYPE_NODE
            end
          when Node::ELEMENT_NODE
            raise HierarchyRequestError if parent.children.any?(&:element?)
            return unless child
            raise HierarchyRequestError if child.type == Node::DOCUMENT_TYPE_NODE
            raise HierarchyRequestError if child.following_node.type == Node::DOCUMENT_TYPE_NODE
          when Node::DOCUMENT_TYPE_NODE
            raise HierarchyRequestError if parent.children.any? {|node|
              node.type == Node::DOCUMENT_TYPE_NODE
            }
            return unless child
            raise HierarchyRequestError if child.preceding_node.element?
            raise HierarchyRequestError if parent.children.any?(&:element?)
          end
        end
      end

      refine Document do
        def adopt(node)
          old_document = node.document
          unless node.document == self
            root << node
            node.remove
          end
          if block_given?
            yield node, old_document
          end
        end
      end

      refine DocumentFragment do
        attr_accessor :host
      end
    end
  end
end
