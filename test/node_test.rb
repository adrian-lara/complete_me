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

  def test_add_child_adds_node_to_children
    parent = Node.new
    parent.add_child('q')
    assert_instance_of Node, parent.children['q']
  end

  def test_add_child_returns_created_node
    parent = Node.new
    assert_instance_of Node, parent.add_child('q')
  end

  def test_add_child_creates_non_end_by_default
    parent = Node.new
    refute parent.add_child('q').end?
  end

  def test_add_child_can_create_end_node
    parent = Node.new
    assert parent.add_child('q', true).end?
  end

  def test_add_child_requires_letter
    assert_raises ArgumentError do
      Node.new.add_child
    end
  end

end
