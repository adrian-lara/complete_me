require 'csv'
require './lib/node'

class CompleteMe

  attr_reader :root

  def initialize
    @root = Node.new
    @selection_history = Hash.new do |selection_history, prefix|
      selection_history[prefix] = Hash.new(0)
    end
  end

  def insert(complete)
    return false if complete == ''
    current = @root
    complete.each_char do |character|
      current.children[character] ||= Node.new
      current = current.children[character]
    end
    return false if current.end?
    current.end_status = true
  end

  def count
    words_using(@root)
  end

  def words_using(node)
    count = if node.end? then 1 else 0 end
    node.children.each_value do |child|
      count += words_using(child)
    end
    count
  end

  def populate(words)
    words.each_line do |word|
      insert(word.chomp)
    end
  end

  def suggest(prefix)
    unordered_suggestions = generate_suggestions(prefix)
    order_suggestions(prefix, unordered_suggestions)
  end

  def select(prefix, word)
    @selection_history[prefix][word] += 1
  end

  def generate_suggestions(initial_prefix)
    initial_node = find_node(initial_prefix)
    return [] if initial_node.nil?

    unchecked_branches = [ [initial_prefix, initial_node] ]
    complete_words = []

    until unchecked_branches.empty?
      current_prefix, current_node = unchecked_branches.pop
      complete_words << current_prefix if current_node.end?

      current_node.children.each_pair do |character, next_node|
        next_prefix = current_prefix + character
        unchecked_branches << [next_prefix, next_node]
      end
    end

    complete_words
  end

  def find_node(prefix)
    current = @root
    prefix.each_char do |character|
      current = current.children[character]
      return nil if current.nil?
    end
    current
  end

  def order_suggestions(prefix, suggestions)
    prefix_usage_stats = @selection_history[prefix]
    suggestions.sort_by { |word| -prefix_usage_stats[word] }
  end

  def populate_from_csv(filename)
    absolute_path = File.absolute_path(filename)
    options = { :headers => :first_row }
    CSV.foreach(absolute_path, options) do |line|
      insert(line[-1])
    end
  end

  def delete(word)
    end_node = find_node(word)
    return false unless end_node.is_a?(Node) && end_node.end?

    if end_node.children.empty?
      steps_back = steps_back_from_end(word)
      delete_unnecessary_nodes(steps_back)
    else
      end_node.end_status = false
    end

    true
  end

  def steps_back_from_end(word)
    current = @root
    steps = []
    word.each_char do |key_from_current|
      steps.unshift([current, key_from_current])
      current = current.children[key_from_current]
    end
    steps
  end

  def delete_unnecessary_nodes(steps_back)
    steps_back.each do |(ancestor, key_to_child)|
      if (
        ancestor.end? ||
        ancestor.children.size > 1 ||
        ancestor.equal?(@root)
      )
        ancestor.children.delete(key_to_child)
        break
      end
    end
  end

end
