require 'csv'
require './lib/node'

class CompleteMe

#root read access added for testing????
  attr_reader :root

  def initialize
    @root = Node.new
    #@selections => @selection_history
    #selections => prefix
    #new_prefix => word_choice
    @selection_history = Hash.new do |selection_history, prefix|
      selection_history[prefix] = Hash.new(0)
    # @selections = Hash.new do |selections, new_prefix|
    #   selections[new_prefix] = Hash.new(0)
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

  def populate(words)
    words.each_line do |word|
      insert(word.chomp)
    end
  end

  def select(prefix, word)
    @selection_history[prefix][word] += 1
  end

  def suggest(prefix)
    unordered_suggestions = generate_suggestions(prefix)
    order_suggestions(prefix, unordered_suggestions)
  end

  def find_node(prefix)
    current = @root
    prefix.each_char do |character|
      current = current.children[character]
      return nil if current.nil?
    end
    current
  end

#word_so_far =>
  def generate_suggestions(prefix)
    start_node = find_node(prefix)
    return [] if start_node.nil?

    incompletes = [ [prefix, start_node] ]
    completes = []
    until incompletes.empty?
      word_so_far, current = incompletes.pop
      completes << word_so_far if current.end?

      current.children.each_pair do |character, child|
        new_word_so_far = word_so_far + character
        incompletes << [new_word_so_far, child]
      end
    end
    completes
  end

  def count
    words_using_node(@root)
  end

  def words_using_node(node)
    count = node.end? ? 1 : 0
    node.children.each_value do |child|
      count += words_using_node(child)
    end
    count
  end

  def order_suggestions(prefix, suggestions)
    prefix_usage_stats = @selection_history[prefix]
    suggestions.sort_by { |word| -prefix_usage_stats[word] }
# suggestions.sort_by { |word| -1 * prefix_usage_stats[word] }
# suggestions.sort_by { |word| descending * prefix_usage_stats[word] }
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
