require 'ru_bee'
require 'rword'


# Generate the pools of vowels and consonants
# The frequency of each letter is obtained from: http://www.thecountdownpage.com/letters.htm
# A string is created by multiplying each letter by their frequency, and then split into an array
def create_letter_pools()
    $vowels = (("A " * 15) + ("E " * 21) + ("I " * 13) + ("O " * 13) + ("U " * 5)).split
    $consonants = ( ("B " * 2) + ("C " * 3) + ("D " * 6) + ("F " * 2) + ("G " * 3) +
                    ("H " * 2) + ("J " * 1) + ("K " * 1) + ("L " * 5) + ("M " * 4) +
                    ("N " * 8) + ("P " * 4) + ("Q " * 1) + ("R " * 9) + ("S " * 9) +
                    ("T " * 9) + ("V " * 1) + ("W " * 1) + ("X " * 1) + ("Y " * 1) +
                    ("Z " * 1) ).split

    # Shuffle the pools
    $vowels.shuffle!
    $consonants.shuffle!
end

create_letter_pools()


scrambled_word = ""

for i in 1..4
    # Add the first letter to the scrambled word
    scrambled_word += " " + $vowels[0]

    # Remove the first letter from the pile
    $vowels = $vowels.drop(1)
end

for i in 1..5
    # Add the first letter to the scrambled word
    scrambled_word += " " + $consonants[0]

    # Remove the first letter from the pile
    $consonants = $consonants.drop(1)
end

# Game section

puts "--------------------"
puts scrambled_word.downcase
puts "--------------------"

puts
print "Enter a word: "

word = gets.chomp

# Check if word is correct using gem
puts word.correct?

# uses all the letters -> need to create function that iterates though different combinations

i = 9

testword = scrambled_word.delete(' ')

testword.downcase!

while i >= 2
    # Generate the words and display the longest ones
    # Maybe randomly pick a long word to display?
    best_words = Rword.generate(testword, i, true)

    if best_words.length > 0
        puts "--------------------"
        puts best_words
        puts "--------------------"
        break
    else
        i -= 1
    end    
end