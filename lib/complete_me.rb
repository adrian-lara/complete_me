require './lib/node'

class CompleteMe

  attr_reader :count
  def initialize
    @root = Node.new
    @count = 0
    @selections = Hash.new do |selections, new_prefix|
      selections[new_prefix] = Hash.new(0)
    end
  end

  def insert(complete)
    current_node = @root
    complete.each_char do |character|
      current_node.children[character] ||= Node.new
      current_node = current_node.children[character]
    end
    current_node.end_status = true

    @count += 1
  end

  def populate(words)
    words.each_line do |word|
      insert word.chomp
    end
  end

  def select(prefix, word)
    @selections[prefix][word] += 1
  end

  def suggest(prefix)
    unordered_suggestions = generate_suggestions(prefix)
    order_suggestions(prefix, unordered_suggestions)
  end

  def find_start_node(prefix)
    current_node = @root
    prefix.each_char do |character|
      current_node = current_node.children[character]
      return nil if current_node.nil?
    end
    current_node
  end

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

  def order_suggestions(prefix, suggestions)
    selection_counts_from_prefix = @selections[prefix]
    suggestions.sort do |a_suggestion, b_suggestion|
      a_count = selection_counts_from_prefix[a_suggestion]
      b_count = selection_counts_from_prefix[b_suggestion]
      b_count <=> a_count
    end
  end

  def populate_from_csv(filename)
    require 'csv'
    absolute_path = File.absolute_path(filename)
    CSV.foreach(absolute_path) do |line|
      insert(line[-1])
    end
  end

end
