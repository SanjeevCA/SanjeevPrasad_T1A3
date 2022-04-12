require 'ru_bee'
require 'rword'

print "Enter a word: "

word = gets.chomp

# Check if word is correct using gem
puts word.correct?

# uses all the letters -> need to create function that iterates though different combinations

i = 9

while i >= 2
    # Generate the words and display the longest ones
    # Maybe randomly pick a long word to display?
    best_words = Rword.generate(word, i, true)

    if best_words.length > 0
        pp best_words
        break
    else
        i -= 1
    end    
end

