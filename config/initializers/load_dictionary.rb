File.readlines('db/words_with_no_clues.txt').each do |words|
  words.split(/\s/).each do |word|
    Dictionary.add(word)
  end
end
# words with clues
File.readlines('db/words_with_clues.csv').each do |line|
  word,clue = line.split(",",2)
  Dictionary.add(word)
  Dictionary.set_clue(word,clue)
end