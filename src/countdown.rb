require 'ru_bee'
require 'rword'
require 'tty-prompt'
require 'colorize'

#                                       -FUNCTIONS-
# ===========================================================================================

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

def draw_letter(array)

    return array.shift
    
end

def pick_letters()
    $scrambled_word = ""

    # Player must choose 9 letters (3 vowels and 4 consonants are a must)
    i = 9
    vowel_num = 3
    cons_num = 4

    while i > 0 
        system 'clear'



        puts "You must choose #{i} more letters. Please pick at #{vowel_num} more vowels and #{cons_num} more consonants."
        puts "-----------------------------------------------------------------------------------------------------------"

        puts $scrambled_word

        puts "-----------------------------------------------------------------------------------------------------------\n\n"
    
        # puts "Vowels: #{$vowels.length}"
        # puts "Cons: #{$consonants.length}"

        # Ask player what letter they would like
        prompt = TTY::Prompt.new
        choice = prompt.select("Would you like a vowel or consonant?", %w(Vowel Consonant))
        puts choice

        if choice == "Vowel"

            # Draw the first vowel off the pile and place in the scrambled word
            # A space is added before the letter for formatting purposes
            $scrambled_word += " " + draw_letter($vowels)

            vowel_num -= 1
        else
            # Draw the first consonant off the pile and place in the scrambled word
            # A space is added before the letter for formatting purposes
            $scrambled_word += " " + draw_letter($consonants)

            cons_num -= 1
        end

        # Iterate
        i -= 1

        puts "Vowels: #{$vowels.length}"
        puts "Cons: #{$consonants.length}"
    end
    

end




#                                       -MAIN PROGRAM-
# ===========================================================================================


create_letter_pools

pick_letters


# Game section

puts "--------------------"
puts $scrambled_word
puts "--------------------"

puts
print "Enter a word: "

word = gets.chomp

# Check if word is correct using gem
puts word.correct?

# uses all the letters -> need to create function that iterates though different combinations

i = 9

testword = $scrambled_word.delete(' ')

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