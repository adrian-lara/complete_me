class Node

  attr_reader :children
  attr_writer :end_status

  def initialize()
    @children = {}
    @end_status = end_status
  end

  def end?
    @end_status
  end

end
