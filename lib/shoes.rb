class Node < Hash
  attr_accessor :is_end_of_word
end

class CompleteMe
  attr_reader :count
  def initialize
    @root = Node.new
    @count = 0
    @selections = Hash.new do |selections, new_prefix|
      selections[new_prefix] = Hash.new(0)
    end
  end

  def insert(word)
    current_node = @root
    word.each_char do |char|
      current_node = current_node[char] ||= Node.new
    end
    current_node.is_end_of_word = true

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
    suggestions = words_starting_with(prefix)
    most_selected_first(prefix, suggestions)
  end

  def node_at(prefix)
    current_node = @root
    prefix.each_char do |char|
      current_node = current_node[char]
      return nil if current_node.nil?
    end
    current_node
  end

  def words_starting_with(prefix)
    start_node = node_at(prefix)
    return [] if start_node.nil?
    incompletes = [ [prefix, start_node] ]
    completes = []
    until incompletes.empty?
       current_sequence, current_node = incompletes.pop
       completes << current_sequence if current_node.is_end_of_word

       current_node.each_pair do |character, child|
         child_sequence = current_sequence + character
         incompletes << [child_sequence, child]
       end
     end
     completes
  end

  def most_selected_first(prefix, suggestions)
    selections_from_prefix = @selections[prefix]
    suggestions.sort do |word_a, word_b|
      count_a = selections_from_prefix[word_a]
      count_b = selections_from_prefix[word_b]
      count_b <=> count_a
    end
  end

  def populate_from_csv(filename)
    #annoyingly specific to that file, but that's csv for ya
    require 'csv'
    absolute_path = File.absolute_path(filename)
    CSV.foreach(absolute_path) do |line|
      full_address = line[-1]
      insert(full_address)
    end
  end

end

Shoes.app do
  cm = CompleteMe.new
  cm.populate File.read("/usr/share/dict/words")
  @input = edit_line do
    @suggestions.clear
    @input.text.empty? ? @chosen.show : @chosen.hide
    top_rated = cm.suggest(@input.text).first(20)
    top_rated.each do |word|
      @suggestions.button word do
        @chosen.para "#{@input.text} ---> #{word}"
        @chosen.show
        cm.select @input.text, word
        @input.text = ''
        @suggestions.clear
      end
    end
  end
  @chosen = stack
  @suggestions = stack
end
