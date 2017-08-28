require 'csv'
require './lib/node'

class CompleteMe

#root read access added for testing????
  attr_reader :count, :root

  def initialize
    @root = Node.new
    @count = 0
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
    current.end_status = true
#TODO don't increase count if word already exists
    @count += 1
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

end
