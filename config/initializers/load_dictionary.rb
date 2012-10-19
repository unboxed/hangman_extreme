# words
File.readlines('db/words.csv').each do |line|
  word,clue = line.split(",",2)
  clue.squish!
  Dictionary.set_clue(word,clue) unless clue.blank?
  Dictionary.add(word)
end