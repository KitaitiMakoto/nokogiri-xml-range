Nokogiri::XML::Range
====================

[![Build Status](https://travis-ci.org/KitaitiMakoto/nokogiri-xml-range.svg?branch=master)](https://travis-ci.org/KitaitiMakoto/nokogiri-xml-range)
[![Coverage Status](https://coveralls.io/repos/KitaitiMakoto/nokogiri-xml-range/badge.svg?branch=master&service=github)](https://coveralls.io/github/KitaitiMakoto/nokogiri-xml-range?branch=master)

* [Homepage](https://rubygems.org/gems/nokogiri-xml-range)
* [Documentation](http://rubydoc.info/gems/nokogiri-xml-range)
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

    require 'nokogiri/xml/range'

Requirements
------------

* Ruby 2.1.0 or later
* Nokogiri gem
* C compiler like gcc to install Nokogiri gem
* `patch` command to install Nokogiri gem

Install
-------

    $ gem install nokogiri-xml-range

Copyright
---------

Copyright (c) 2015 KITAITI Makoto

See {file:COPYING.txt} for details.
