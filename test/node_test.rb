require './test/test_helper'

require 'minitest/autorun'
require 'minitest/emoji'

require './lib/node'


class NodeTest < MiniTest::Test

  def test_it_exists
    Node.new
  end

  def test_it_is_not_an_end_by_default
    refute Node.new.is_end_of_word
  end

  def test_it_can_be_an_end
    node = Node.new
    node.is_end_of_word = true
    assert node.is_end_of_word
  end

  def test_children_starts_empty
    assert Node.new.empty?
  end

  def test_it_can_have_children
    node = Node.new
    node[:a] = 1
    assert_equal 1, node[:a]
  end


end
