Nokogiri::XML::Range
====================

[![Build Status](https://travis-ci.org/KitaitiMakoto/nokogiri-xml-range.svg?branch=master)](https://travis-ci.org/KitaitiMakoto/nokogiri-xml-range)
[![Coverage Status](https://coveralls.io/repos/KitaitiMakoto/nokogiri-xml-range/badge.svg?branch=master&service=github)](https://coveralls.io/github/KitaitiMakoto/nokogiri-xml-range?branch=master)
[![Gem Version](https://badge.fury.io/rb/nokogiri-xml-range.svg)](http://badge.fury.io/rb/nokogiri-xml-range)

* [Homepage](https://rubygems.org/gems/nokogiri-xml-range)
* [Documentation](http://rubydoc.info/gems/nokogiri-xml-range)
* [Source code](https://github.com/KitaitiMakoto/nokogiri-xml-range)
* [Email](mailto:KitaitiMakoto at gmail.com)

DOM Range implementation on Nokogiri

Description
-----------

[Nokogiri][] DOM Range Implementatin based on [DOM Standard specification][range spec].

[Nokogiri]: http://www.nokogiri.org/
[range spec]: https://dom.spec.whatwg.org/#ranges

Features
--------

`Nokogiri::XML::Range` expresses a range on DOM tree. It can:

* test a node is in the range or not,
* delete contents the range expresses from DOM tree,
* extract contents alike,
* clone contents alike,
* surround the range by specified DOM element,
* and so on...

Examples
--------

### Initialization ###

    require 'nokogiri/xml/range'
    
    doc = Nokogiri.XML(<<EOX)
    <root>
      <parent>
        <child>child 1</child>
        <child>child 2</child>
      </parent>
    </root>
    EOX
    parent = doc.search('parent')[0]
    child1 = doc.search('child')[0]
    child2 = doc.search('child')[1]
    child1_text = child1.child
    child2_text = child2.child

    # Initialize range with nodes and offsets of start and end point
    range = Nokogiri::XML::Range.new(child1_text, 0, child2_text, 5)

    # This range expresses `child 1</child>\n        <child>child`

### Deleting contents ###

    range.delete_contents
    puts doc
    # <?xml version="1.0"?>
    # <root>
    #   <parent>
    #     <child></child><child> 2</child>
    #   </parent>
    # </root>

### Extracting contents ###

`Nokogiri::XML::Range#extract_contents` remove the range from DOM tree and returns contents in the range.

    extracted = range.extract_contents
    # => #(DocumentFragment:0x3fa87891eaa0 {
    #   name = "#document-fragment",
    #   children = [
    #     #(Element:0x3fa87891e12c { name = "child", children = [ #(Text "child 1")] }),
    #     #(Text "\n        "),
    #     #(Element:0x3fa8789177f0 { name = "child", children = [ #(Text "child")] })]
    #   })
    puts doc
    # <?xml version="1.0"?>
    # <root>
    #   <parent>
    #     <child></child><child> 2</child>
    #   </parent>
    # </root>
    puts extracted
    # <child>child 1</child>
    #     <child>child</child>

### Cloning contents ###

    cloned = range.clone_contents
    # => #(DocumentFragment:0x3fa87809fb90 {
    #   name = "#document-fragment",
    #   children = [
    #     #(Element:0x3fa87809e394 { name = "child", children = [ #(Text "child 1")] }),
    #     #(Text "\n        "),
    #     #(Element:0x3fa87808dcd8 { name = "child", children = [ #(Text "child")] })]
    #   })
    puts cloned
    # <child>child 1</child>
    #     <child>child</child>

`Nokogiri::XML::Range#clone_contents` doesn't affect original DOM tree.

### Inserting node ###

`Nokogiri::XML::Range#insert_node` inserts a node just before the range start point.

    text = Nokogiri::XML::Text.new('inserted', doc)
    # => #(Text "inserted")
    range.insert_node text
    puts doc
    # <?xml version="1.0"?>
    # <root>
    #   <parent>
    #     <child>insertedchild 1</child>
    #     <child>child 2</child>
    #   </parent>
    # </root>

### Surrounding range contents ###

    range = Nokogiri::XML::Range.new(child1_text, 6, child1_text, 7)
    number = Nokogiri::XML::Element.new('number', doc)
    range.surround_contents number
    puts doc
    # <?xml version="1.0"?>
    # <root>
    #   <parent>
    #     <child>child <number>1</number></child>
    #     <child>child 2</child>
    #   </parent>
    # </root>

Requirements
------------

* Ruby 2.1.0 or later
* Nokogiri gem
* C compiler like gcc to install Nokogiri gem
* `patch` command to install Nokogiri gem

Install
-------

    $ gem install nokogiri-xml-range

Todos
-----

* Helpful error messages
* C0 coverage 100%
* More test cases from use cases in the wild
* Performance optimization, especially caching

Copyright
---------

Copyright (c) 2015 KITAITI Makoto

See {file:COPYING.txt} for details.
