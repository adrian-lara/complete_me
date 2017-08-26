require './lib/node'

class CompleteMe

  def initialize
    @root = Node.new
    @count = 0
    @selections = Hash.new do |selections, new_prefix|
      selections[new_prefix] = Hash.new(0)
    end
  end

  def insert(word)

  end

  def select(prefix, word)
    @selections[prefix][word] += 1
  end

  def suggest(prefix, start)
    unordered_suggestions = generate_suggestions
    order_suggestions(unordered_suggestions)
  end

  def find_start_node(prefix)
    current_node = @root
    prefix.each_char do |character|
      current_node = current_node.children[character]
      return nil if current_node.nil?
    end
    current_node
  end

  def generate_suggestions(prefix, start_node)
    start_node = find_start_node(prefix)
    incompletes = []
    complete = []
    incompletes << [prefix, start]
    until incompletes.empty?
       word_so_far, working = incompletes.pop
       complete << word_so_far if working.end?

       working.each_pair do |character, child|
         new_word_so_far = word_so_far + character
         incompletes << [new_word_so_far, child]
       end
     end
  end

  def order_suggestions(prefix, suggestions)
    selections_from_prefix = @selections[prefix]
    suggestions.sort do |a_suggestion, b_suggestion|
      a_count = selection_counts_from_prefix[a_suggestions]
      b_count = selection_counts_from_prefix[b_suggestions]
      b_count <=> a_count
    end
  end

end
