
class CompleteMe

  def suggest(prefix, @root)
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

end
