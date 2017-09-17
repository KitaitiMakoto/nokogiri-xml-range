require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'pp'
require 'rubygems'
require 'test/unit'
require 'test/unit/notify'
require 'pry'

class Test::Unit::TestCase
end
