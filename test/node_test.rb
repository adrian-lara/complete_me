require 'minitest/autorun'
require 'minitest/emoji'

require './test/test_helper'
require './lib/node'


class NodeTest < MiniTest::Test

  def test_it_exists
    Node.new
  end

  def test_it_is_not_an_end_by_default
    refute Node.new.end?
  end

  def test_it_can_be_an_end
    assert Node.new(true).end?
  end

  def test_it_has_children
    node = Node.new
    assert_instance_of Hash, node.children
  end

  def test_children_starts_empty
    node = Node.new
    assert node.children.empty?
  end

end
