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
require 'timeout'
require 'tty-progressbar'

$pastel = Pastel.new

# Progress bar for finding best work (as it can be a lengthy process)
$bar = TTY::ProgressBar.new("[:bar]", bar_format: :blade, total: 100)
$best_words = []

$scores = []
$best_played_word = ""

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

        # puts $pastel.bold.white.on_blue($scrambled_word)
        puts $pastel.bold.white.on_blue(" " + ($scrambled_word.split("").map { |c| c + " "}).join)

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
def play_word

    message = ""

    # Timer setup
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    play_time = 31

    begin
        # Code will be interrupted after 30 seconds
        timer = Timeout::timeout(play_time) {   
                     
            while true
                system 'clear'        
        
                puts "Try and find the longest possible word. Using each letter only ONCE."
                puts "-----------------------------------------------------------------------"
                
                # Split the string, add spaces, join the string again
                puts $pastel.bold.white.on_blue(" " + ($scrambled_word.split("").map { |c| c + " "}).join)
                
                puts "-----------------------------------------------------------------------"

                time_left = (play_time - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time)).to_i
                puts "You have less than #{time_left}s remaining!"
        
                puts message
                
                print "Enter a word: "
                
                # Remove all whitespace and brackets
                word = gets.chomp.gsub(/\s+/, '').upcase
                
                # Check if word uses only the letters provided
                word_to_array = word.split("")
                letters_available = $scrambled_word.split("")
        
                # Check if word is correct using gem
                if word.correct? && compare_word_arrays(word_to_array, letters_available) && word != ""
                    puts "\n#{(" "+ word +" ").upcase.black.on_light_green} is valid and scores #{score(word)} points!\n\n"
                    return word
                    break
                else
                    message = "\n#{(" "+ word +" ").upcase.white.on_red} is invalid. Try another word.\n\n"
                end
            end
        }
    rescue
        puts
        puts '--------------------------------------------'
        puts "TIME IS UP!"
        puts '--------------------------------------------'
        return ""
    end


    

end

# Define a word
def define(word)
    begin
        # Go to the word page on dictionary.com
        url = 'https://www.dictionary.com/browse/'+ word

        # Scrape the HTML of the page using Nokogiri
        document = Nokogiri::HTML(URI.open(url))

        # Search for the definition by finding the element where value=1 in the HTML code.
        # This denotes the first definition
        return document.at_css('[value="1"]').to_str.capitalize
    rescue
        return "Sorry, a definition could not be found."
    end

end

# Score a word
def score(word)

    # One point for each letter used
    value = word.length

    # Words using all 9 letters score 18
    if value == 9
        value = 18
    end

    $scores << value
    return value
end

# The best possible answer that could be played is shown to the player, along with a definition
def best_word

    puts
    puts "Searching dictionary for best playable word: "

    # uses all the letters -> need to create function that iterates though different combinations
    i = 9

    # Find the best possible words and show a progress bar 
    $bar.reset
    response = $bar.iterate($find_word, 20).to_a.join

    # Limit the best words to only 4
    if $best_words.length > 4                
        $best_words = $best_words.sample(4)
    end

    # shuffle the words so no longer alphabetical
    $best_words.shuffle!

    # Find and display the definition of the top word.
    define_word = $best_words[0]
    $best_words = $best_words.drop(1)
    puts "-----------------------------------------------------------------------"
    puts define_word.upcase.yellow.underline
    puts
    puts WordWrap.ww($pastel.italic.dim.yellow(define(define_word)), 80)


    if $best_words.length > 0
        puts "-----------------------------------------------------------------------"
        print "Other possible word(s): "
        print $best_words.join(", ")
        puts
    end
end

# Enumerator to find the best word using 'rword' gem
# Progress will be yeilded so that it can be displayed in a progress bar
$find_word = Enumerator.new do |y|

    # setup variables
    $best_words = []
    testword = $scrambled_word.delete(' ')
    testword.downcase!

    # Keep count of iterations
    count = 0

    # Find possible words starting at 9 letters and then iterating down
    i = 9
    while i > 0

        # Increment progress bar with each iteration
        count += 1
        y.yield(count)

        # Gem returns an array of possible words of length i
        $best_words = Rword.generate(testword, i, true)

        # If words are generated
        if $best_words.length > 0 
            $bar.finish
            break
        else
            i -= 1
        end
    end
end

def player_stats(word)

    if word.length > $best_played_word.length
        $best_played_word = word
    end
    total_score = $scores.sum
    average_score = (total_score.to_f / $scores.size).round(2)

    puts
    puts "-----------------------------------------------------------------------"
    puts "Total Score: #{total_score.to_s.green} \t Average Score: #{average_score.to_s.green} \t Best Word Played: #{$best_played_word.green}"
    
end

#                                       -MAIN PROGRAM-
# ===========================================================================================

while true

    create_letter_pools

    pick_letters

    word = play_word

    best_word

    player_stats(word)

    puts "-----------------------------------------------------------------------"
    # Play again?
    prompt = TTY::Prompt.new
    choice = prompt.select("Would you like to play again?", %w(Yes No))
    puts "\n\n"
    if choice == "No"
        break
    end
    

end

