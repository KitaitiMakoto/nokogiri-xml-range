require 'nokogiri/xml/range/version'
require 'nokogiri'
require 'nokogiri/xml/range/extension'

using Nokogiri::XML::Range::Extension

module Nokogiri::XML
  class Range
    START_TO_START = 0
    START_TO_END = 1
    END_TO_END = 2
    END_TO_START = 3

    class InvalidNodeTypeError < StandardError; end
    class IndexSizeError < StandardError; end

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
    end
    alias end= set_end

    def collapsed?
      @start_offset == @end_offset and
        @start_container == @end_container
    end

    def common_ancestor_container
      container = @start_container
      ancestors_of_end = @end_container.ancestors
      until ancestors_of_end.include?(container)
        container = container.parent
      end
      container
    end

    def select_node(node)
    end

    def select_node_contents(node)
    end

    def compare_boundary_points(how, source_range)
    end

    def delete_contents
    end

    def extract_contents
    end

    def clone_contents
    end

    def insert_node(node)
    end

    def surround_contents(new_parent)
    end

    def clone_range
    end

    def contain?(node)
      document == node.document and
        self.class.compare_points(@start_container, @start_offset, node, 0) <= 0 and
        self.class.compare_points(node, node.length, @end_container, @end_offset) == -1
    end
    alias include? contain?
    alias cover? contain?

    def partially_contain?(node)
      path_to_start = @start_container.ancestors_to(node)
      path_to_end = @end_container.ancestors_to(node)
      !path_to_start.nil? && path_to_end.nil? or
        path_to_start.nil? && !path_to_end.nil?
    end
    alias partially_include? partially_contain?
    alias partially_cover? partially_contain?

    def point_in_range?(node, offset)
    end

    def compare_point(node, offset)
    end

    def intersect_node?(node)
    end

    def to_s
    end
  end
end
