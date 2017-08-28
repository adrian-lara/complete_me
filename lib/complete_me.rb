require 'csv'
require './lib/node'

class CompleteMe

  #root read access added for testing????
  attr_reader :count, :root

  def initialize
    @root = Node.new
    @count = 0
    @selections = Hash.new do |selections, new_prefix|
      selections[new_prefix] = Hash.new(0)
    end
  end

  def insert(word)
    @count += 1

    working = @root
    word.each_char do |character|
      working.children[character] ||= Node.new
      working = working.children[character]
    end
    working.end_status = true
  end

#added parenthesis for insert argument
  def populate(words)
    words.each_line do |line|
      insert(line.chomp)
    end
  end

  def select(prefix, word)
    @selections[prefix][word] += 1
  end

  def suggest(prefix)
    unordered_suggestions = generate_suggestions(prefix)
    order_suggestions(prefix, unordered_suggestions)
  end

#find_start_node => find_node
#current_node => current
  def find_start_node(prefix)
    current_node = @root
    prefix.each_char do |character|
      return nil if current_node.children.empty? #is this more readable??
      current_node = current_node.children[character]
      # return nil if current_node.nil?
    end
    current_node
  end

#working => current
#change to accomodate the case that prefix doesnt lead to any word
  def generate_suggestions(prefix)
    start_node = find_start_node(prefix)
    incompletes = []
    completes = []
    incompletes << [prefix, start_node]
    until incompletes.empty?
       word_so_far, working = incompletes.pop
       completes << word_so_far if working.end?

       working.children.each_pair do |character, child|
         new_word_so_far = word_so_far + character
         incompletes << [new_word_so_far, child]
       end
     end
     completes
  end

#selection_counts_from_prefix => prefix_usage_stats
#use sort_by vs sort
  def order_suggestions(prefix, suggestions)
    prefix_usage_stats = @selections[prefix]
    suggestions.sort_by { |word| -1 * prefix_usage_stats[word] }
  end

#added option to ignore header
#moved require 'csv' to top
  def populate_from_csv(filename)
    absolute_path = File.absolute_path(filename)
    CSV.foreach(absolute_path, { :headers => :first_row }) do |line|
      insert(line[-1])
    end
  end

end
