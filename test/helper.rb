require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/test/'
end

require 'pp'
require 'rubygems'
require 'test/unit'
require 'test/unit/notify'
require 'pry'

class Test::Unit::TestCase
end
