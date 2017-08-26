require 'blah blah blah'


class Whatever

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
    assert node.children.empty
  end

  def test_add_child_creates_nodes
    node = Node.new

  end

end
