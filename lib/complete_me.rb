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
def generate_suggestions(initial_prefix)
  start_node = find_node(initial_prefix)
  return [] if start_node.nil?

  incompletes = [ [initial_prefix, start_node] ]
  completes = []
  until incompletes.empty?
    substring, node = incompletes.pop
    completes << substring if node.end?

    node.children.each do |character, child_node|
      child_substring = substring + character
      incompletes << [child_substring, child_node]
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
    current = @root
    ancestors = []
    word.each_char do |char|
      ancestors.unshift([current, char])
      current = current.children[char]
      return false if current.nil?
    end
    return false unless current.end?
    if current.children.empty?
      ancestors.each do |(ancestor, key_to_child)|
        break ancestor.children.delete(key_to_child) if (
          ancestor.end? ||
          ancestor.children.size > 1 ||
          ancestor.equal?(@root)
        )
      end
    else
      current.end_status = false
    end
    return true
  end


end
