# coding: utf-8
require 'nokogiri/xml/range/version'
require 'nokogiri'
require 'nokogiri/xml/range/extension'
require 'nokogiri/xml/replacable'

using Nokogiri::XML::Range::Extension

module Nokogiri::XML
  class InvalidNodeTypeError < StandardError; end
  class IndexSizeError < StandardError; end
  class NotSupportedError < StandardError; end
  class WrongDocumentError < StandardError; end
  class HierarchyRequestError < StandardError; end

  class Range
    START_TO_START = 0
    START_TO_END = 1
    END_TO_END = 2
    END_TO_START = 3

    class << self
      def compare_points(node1, offset1, node2, offset2)
        return unless node1.document == node2.document

        case node1 <=> node2
        when 0
          offset1 <=> offset2
        when 1
          compare_points(node2, offset2, node1, offset1) * -1
        else
          ancestors = node2.ancestors_to(node1) # nil or [node2, parent of node2, ..., child of node1, node1]
          if ancestors
            child = nil
            ancestors.reverse_each do |anc|
              child = anc if anc.parent == node1
            end
            if node1.children.index(child) < offset1
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

    attr_reader :start_container, :start_offset, :end_container, :end_offset
    alias start_node start_container
    alias end_node end_container

    def initialize(start_container, start_offset, end_container, end_offset)
      @start_container, @start_offset, @end_container, @end_offset =
        start_container, start_offset, end_container, end_offset
    end

    def start_point
      [@start_container, @start_offset]
    end

    def end_point
      [@end_container, @end_offset]
    end

    def document
      @start_container.document
    end

    def root
      document.root
    end

    def set_start(node, offset)
      validate_boundary_point node, offset
      if document != node.document or
        self.class.compare_points(node, offset, @end_container, @end_offset) == 1
        set_end node, offset
      end
      @start_container, @start_offset = node, offset
    end
    alias start= set_start

    def set_end(node, offset)
      validate_boundary_point node, offset
      if document != node.document or
        self.class.compare_points(node, offset, @start_container, @start_offset) == -1
        set_start node, offset
      end
      @end_container, @end_offset = node, offset
    end
    alias end= set_end

    def set_start_before(node)
      parent = node.parent
      raise InvalidNodeTypeError, 'parent node is empty' unless parent
      set_start(parent, parent.children.index(node))
    end

    def set_start_after(node)
      parent = node.parent
      raise InvalidNodeTypeError, 'parent node is empty' unless parent
      set_start(parent, parent.children.index(node) + 1)
    end

    def set_end_before(node)
      parent = node.parent
      raise InvalidNodeTypeError, 'parent node is empty' unless parent
      set_end(parent, parent.children.index(node))
    end

    def set_end_after(node)
      parent = node.parent
      raise InvalidNodeTypeError, 'parent node is empty' unless parent
      set_end(parent, parent.children.index(node) + 1)
    end

    def collapsed?
      @start_offset == @end_offset and
        @start_container == @end_container
    end

    def collapse(to_start=false)
      to_start ? set_end(*start_point) : set_start(*end_point)
    end
    alias collapse! collapse

    def common_ancestor_container
      container = @start_container
      ancestors_of_end = [@end_container] + @end_container.ancestors
      until ancestors_of_end.include?(container)
        container = container.parent
      end
      container
    end

    def select_node(node)
      parent = node.parent
      raise InvalidNodeTypeError, 'parent node is empty' unless parent
      index = parent.children.index(node)
      set_start parent, index
      set_end parent, index + 1
    end

    def select_node_contents(node)
      raise InvalidNodeTypeError, 'document type declaration is passed' if node.type == Node::DOCUMENT_TYPE_NODE
      set_start node, 0
      set_end node, node.length
    end

    def compare_boundary_points(how, source_range)
      raise WrongDocumentError, 'different document' unless source_range.document == document
      this_point, other_point =
        case how
        when START_TO_START
          [start_point, source_range.start_point]
        when START_TO_END
          [end_point, source_range.start_point]
        when END_TO_END
          [end_point, source_range.end_point]
        when END_TO_START
          [start_point, source_range.end_point]
        else
          raise NotSupportedError, 'unsupported way to compare'
        end
      self.class.compare_points(this_point[0], this_point[1], other_point[0], other_point[1])
    end

    def delete_contents
      return if collapsed?

      if @start_container == @end_container and @start_container.replacable?
        @start_container.replace_data @start_offset, @end_offset - @start_offset, ''
        return
      end

      nodes_to_remove = NodeSet.new(document)
      common_ancestor = common_ancestor_container
      select_containing_node common_ancestor, nodes_to_remove

      if @end_container.ancestors_to @start_container
        new_node, new_offset = @start_container, @start_offset
      else
        reference_node = @start_container
        parent = reference_node.parent
        while parent and !@end_container.ancestors_to(parent)
          reference_node = parent
          parent = reference_node.parent
        end
        new_node = parent
        new_offset = parent.children.index(reference_node) + 1
      end

      if @start_container.replacable?
        @start_container.replace_data @start_offset, @start_container.length - @start_offset, ''
      end

      nodes_to_remove.each &:remove

      if @end_container.replacable?
        @end_container.replace_data 0, @end_offset, ''
      end

      @start_container = @end_container = new_node
      @start_offset = @end_offset = new_offset
    end

    def extract_contents
      fragment = DocumentFragment.new(document)
      return fragment if collapsed?

      if @start_container == @end_container and @start_container.replacable?
        cloned = @start_container.clone(0)
        cloned.content = @start_container.substring_data(@start_offset, @end_offset - @start_offset)
        fragment << cloned
        @start_container.replace_data @start_offset, @end_offset - @start_offset, ''
      end
      common_ancestor = common_ancestor_container
      end_node_ancestors = [@end_container] + @end_container.ancestors
      first_partially_contained_child =nil
      unless end_node_ancestors.include? @start_container
        first_partially_contained_child = common_ancestor.children.find {|child|
          partially_contain_node? child
        }
      end
      last_partially_contained_child = nil
      unless @start_container.ancestors_to @end_container
        last_partially_contained_child = common_ancestor.children.reverse.find {|child|
          partially_contain_node? child
        }
      end
      contained_children = common_ancestor.children.select {|child|
        contain_node? child
      }
      raise HierarchyRequestError if contained_children.any? {|child|
        child.type == Node::DOCUMENT_TYPE_NODE
      }

      if end_node_ancestors.include? @start_container
        new_node, new_offset = @start_container, @start_offset
      else
        reference_node = @start_container
        parent = reference_node.parent
        while parent and !end_node_ancestors.include?(parent)
          reference_node = reference_node.parent
          parent = reference_node.parent
        end
        new_node = parent
        new_offset = parent.children.index(reference_node) + 1
      end

      if first_partially_contained_child && first_partially_contained_child.replacable?

        cloned = @start_container.clone(0)
        cloned.content = @start_container.substring_data(@start_offset, @start_container.length - @start_offset)
        fragment << cloned
        @start_container.replace_data @start_offset, @start_container.length - @start_offset, ''
      elsif first_partially_contained_child
        cloned = first_partially_contained_child.clone(0)
        fragment << cloned
        subrange = Range.new(@start_container, @start_offset, first_partially_contained_child, first_partially_contained_child.length)
        subfragment = subrange.extract_contents
        cloned << subfragment
      end
      contained_children.each do |contained_child|
        fragment << contained_child
      end
      if last_partially_contained_child && last_partially_contained_child.replacable?

        cloned = @end_container.clone(0)
        cloned.content = @end_container.substring_data(0, @end_offset)
        fragment << cloned
        @end_container.replace_data 0, @end_offset, ''
      elsif last_partially_contained_child
        cloned = last_partially_contained_child.clone(0)
        fragment << cloned
        subrange = Range.new(last_partially_contained_child, 0, @end_container, @end_offset)
        subfragment = subrange.extract_contents
        cloned << subfragment
      end
      @start_container = @end_container = new_node
      @start_offset = @end_offset = new_offset
      fragment
    end

    def clone_contents
      fragment = DocumentFragment.new(document)
      return fragment if collapsed?

      if @start_container == @end_container and @start_container.replacable?
        cloned = @start_container.clone(0)
        cloned.content = @start_container.substring_data(@start_offset, @end_offset - @start_offset)
        fragment << cloned
        return fragment
      end

      common_ancestor = common_ancestor_container
      first_partially_contained_child = nil
      @end_node_ancestors = [@end_container] + @end_container.ancestors
      unless @end_node_ancestors.include?(@start_container)
        first_partially_contained_child = common_ancestor.children.find {|child|
          partially_contain_node? child
        }
      end
      last_partially_contained_child = nil
      unless ([@start_container] + @start_container.ancestors).include? @end_container
        last_partially_contained_child = common_ancestor.children.reverse.find {|child|
          partially_contain_node? child
        }
      end

      contained_children = common_ancestor.children.select {|child|
        contain_node? child
      }

      raise HierarchyRequestError if contained_children.any? {|child|
        child.type == Node::DOCUMENT_TYPE_NODE
      }

      if first_partially_contained_child && first_partially_contained_child.replacable?

        cloned = @start_container.clone(0)
        cloned.content = @start_container.substring_data(@start_offset, @start_container.length - @start_offset)
        fragment << cloned
      elsif first_partially_contained_child
        cloned =first_partially_contained_child.clone(0)
        fragment << cloned
        subrange = self.class.new(@start_container, @start_offset, first_partially_contained_child, first_partially_contained_child.length)
        subfragment = subrange.clone_contents
        cloned << subfragment
      end

      contained_children.each do |contained_child|
        cloned = contained_child.clone(1)
        fragment << cloned
      end

      if last_partially_contained_child && last_partially_contained_child.replacable?
        cloned = @end_container.clone(0)
        cloned.content = @end_container.substring_data(0, @end_offset)
        fragment << cloned
      elsif last_partially_contained_child
        cloned = last_partially_contained_child.clone(0)
        fragment << cloned
        subrange = self.class.new(last_partially_contained_child, 0, @end_container, @end_offset)
        subfragment = subrange.clone_contents
        cloned << subfragment
      end

      fragment
    end

    def insert_node(node)
    end

    def surround_contents(new_parent)
    end

    def clone_range
    end

    def contain_node?(node)
      document == node.document and
        self.class.compare_points(node, 0, @start_container, @start_offset) == 1 and
        self.class.compare_points(node, node.length, @end_container, @end_offset) == -1
    end
    alias include_node? contain_node?
    alias cover_node? contain_node?

    def partially_contain_node?(node)
      path_to_start = @start_container.ancestors_to(node)
      path_to_end = @end_container.ancestors_to(node)
      !path_to_start.nil? && path_to_end.nil? or
        path_to_start.nil? && !path_to_end.nil?
    end
    alias partially_include_node? partially_contain_node?
    alias partially_cover_node? partially_contain_node?

    def point_in_range?(node, offset)
    end

    def compare_point(node, offset)
    end

    def intersect_node?(node)
    end

    def to_s
    end

    private

    def validate_boundary_point(node, offset)
      raise InvalidNodeTypeError, 'document type declaration cannot be a boundary point' if node.type == Node::DOCUMENT_TYPE_NODE
      raise IndexSizeError, 'offset is greater than node length' if offset > node.length
    end

    # @note depth first order
    # @note modifies +node_set+
    def select_containing_node(node, node_set)
      if contain_node?(node)
        node_set << node
      else
        node.children.each do |child|
          select_containing_node child, node_set
        end
      end
    end
  end
end
