# Do not display deprecation warning messages from gems.
# original_verbosity = $VERBOSE
# $VERBOSE = nil

require 'ru_bee'
require 'rword'
require 'tty-prompt'
require 'colorize'
require 'pastel'
require 'word_wrap'
require 'nokogiri'
require 'open-uri'

# require_relative './define'

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

# Draw a letter from the pile in the argument
def draw_letter(array)

    return array.shift
    
end

# The letter picking loop/process
def pick_letters()
    $scrambled_word = ""

    # Player must choose 9 letters (3 vowels and 4 consonants are a must)
    i = 9
    vowel_num = 3
    cons_num = 4

    while i > 0 
        system 'clear'

        choose_text = ""

        # Display how many more vowels & consonants need to be picked
        if vowel_num > 0
            choose_text += " #{vowel_num} more vowels."
        end

        if cons_num > 0
            choose_text += " #{cons_num} more consonants."
        end
        
        if choose_text.length > 0
            choose_text = " Please pick:" + choose_text
        end

        puts "You must choose #{i} more letters." + choose_text
        puts "-----------------------------------------------------------------------"

        puts $scrambled_word

        puts "-----------------------------------------------------------------------\n\n"
    
        # If the remaining letters to be picked equal the remaining vowels to be picked
        # then automatically pick the remaining vowels
        if i <= vowel_num
            $scrambled_word += draw_letter($vowels)
            vowel_num -= 1
            sleep(0.2) # slow the program down to see the letters being picked automatically

        # Same with the consonants 
        elsif i <= cons_num
            $scrambled_word += draw_letter($consonants)
            cons_num
            sleep(0.2)            

        else # Ask player what letter they would like
            
            prompt = TTY::Prompt.new
            choice = prompt.select("Would you like a vowel or consonant?", %w(Vowel Consonant))

            if choice == "Vowel"

                # Draw the first vowel off the pile and place in the scrambled word
                # A space is added before the letter for formatting purposes
                # $scrambled_word += " " + draw_letter($vowels)
                $scrambled_word += draw_letter($vowels)

                vowel_num -= 1
            else
                # Draw the first consonant off the pile and place in the scrambled word
                # A space is added before the letter for formatting purposes
                $scrambled_word += draw_letter($consonants)

                cons_num -= 1
            end
        end

        # Iterate
        i -= 1

    end # End while
    
    sleep(0.2) 

end

# Check to see if the user used only the available letters
def compare_word_arrays(player_word, letter_pool)

    valid = true
    
    # pp player_word

    player_word.each {|c|
        
        if letter_pool.include?(c)
            letter_pool.delete_at(letter_pool.index(c))
            # letter_pool.delete_at(letter_pool.index(c) || letter_pool.length)
        else
            valid = false
        end
    }

    return valid
end

# Allow the player to input a word and check its validity
def play_words

    message = ""

    # Loop until 30 seconds / player enters a valid word
    while true
        system 'clear'        

        puts "Try and find the longest possible word. Using each letter only ONCE."
        puts "-----------------------------------------------------------------------"
        
        # Split the string, add spaces, join the string again
        puts ($scrambled_word.split("").map { |c| c + " "}).join
        
        puts "-----------------------------------------------------------------------"

        puts message
        
        print "Enter a word: "
        
        # Remove all whitespace and brackets
        word = gets.chomp.gsub(/\s+/, '').upcase
        # word = word.gsub(/\[+$/, '')
        
        # Check if word uses only the letters provided
        word_to_array = word.split("")
        letters_available = $scrambled_word.split("")

        # Check if word is correct using gem
        if word.correct? && compare_word_arrays(word_to_array, letters_available) && word != ""
            puts "\n#{(" "+ word +" ").upcase.black.on_light_green} is valid.\n\n"
            break
        else
            message = "\n#{(" "+ word +" ").upcase.black.on_red} is invalid. Try another word.\n\n"
        end
    end

end

# Define a word
def define(word)

    # Go to the word page on dictionary.com
    url = 'https://www.dictionary.com/browse/'+ word

    # Scrape the HTML of the page using Nokogiri
    document = Nokogiri::HTML(URI.open(url))

    # Search for the definition by finding the element where value=1 in the HTML code.
    # This denotes the first definition
    return document.at_css('[value="1"]').to_str.capitalize
end

# The best possible answer that could be played is shown to the player, along with a definition
def best_word

    # uses all the letters -> need to create function that iterates though different combinations
    i = 9

    testword = $scrambled_word.delete(' ')
    testword.downcase!

    while i >= 2
        # Generate the words and display the longest ones
        # Maybe randomly pick a long word to display?

        # Add all possible words (en_us) of length (i) to an array
        best_words = Rword.generate(testword, i, true)

        if best_words.length > 0

            # Limit the best words to only 3
            if best_words.length > 3                
                best_words = best_words.sample(3)
            end
        
            # shuffle the words so no longer alphabetical
            best_words.shuffle!

            # puts "--------------------"
            # puts best_words
            # puts "--------------------"

            # Find and display the definition of the top word.
            pastel = Pastel.new
            define_word = best_words[0]
            best_words = best_words.drop(1)
            puts "-----------------------------------------------------------------------"
            puts define_word.upcase.yellow.underline
            puts
            puts WordWrap.ww(pastel.italic.dim.yellow(define(define_word)), 80)
            puts "-----------------------------------------------------------------------"

            if best_words.length > 0
                puts
                puts "Other possible word(s): #{best_words}"
            end

            puts

            break
        else
            i -= 1
        end    
    end

end


#                                       -MAIN PROGRAM-
# ===========================================================================================

while true

    create_letter_pools

    pick_letters

    play_words

    best_word

    puts "-----------------------------------------------------------------------"
    # Play again?
    prompt = TTY::Prompt.new
    choice = prompt.select("Would you like to play again?", %w(Yes No))

    if choice == "No"
        break
    end
    

end

