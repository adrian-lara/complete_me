class Node

  attr_reader :children
  def initialize(end_status = false)
    @children = {}
    @end_status = end_status
  end

  def end?
    @end_status
  end

  def add_child(letter, end_status = false)
    children[letter] = Node.new(end_status)
  end

end
