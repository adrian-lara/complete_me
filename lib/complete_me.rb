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

  def suggest(prefix, start = @root)
    start = find(prefix) #start = whole node
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

  def select(prefix, word)
    @selections[prefix][word] += 1
  end

end
