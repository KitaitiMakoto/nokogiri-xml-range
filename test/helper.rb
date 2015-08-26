require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'pp'
require 'rubygems'
require 'test/unit'
require 'test/unit/notify'

class Test::Unit::TestCase
end
