#                                         -GEMS-
# ===========================================================================================

# Playing words
require 'ru_bee'  # Checking user input words for misspellings
require 'rword'   # Generate best words from the scrambled letters
require 'timeout' # Limit rounds to 30 seconds

# Formatting
require 'tty-prompt'        # Prompts for user input
require 'tty-progressbar'   # Show progress bar for time consuming functions
require 'artii'             # Banner display
require 'pastel'            # Colour formatting
require 'word_wrap'         # Wrapping large blocks of text neatly

# Accessing web dictionary for definitions / word of the day
require 'nokogiri'
require 'open-uri'

#                                       -VARIABLES-
# ===========================================================================================

# Formatting variables
$pastel = Pastel.new
$screen_width = 75
$bar = TTY::ProgressBar.new('[:bar]', total: $screen_width)
$divider = '-' * ($screen_width + 1)

# Score keeping variables
$best_words = []
$scores = []
$best_played_word = ''
$play_time = 30

#                                       -FUNCTIONS-
# ===========================================================================================

# ASCII logo/banner at the top of page
def print_logo
  # ASCII Banner art
  a = Artii::Base.new font: 'ogre'
  puts $pastel.bold.white.on_blue(a.asciify('   c o u n t d o w n   '))

  # Subtitle
  puts $pastel.bold.white.on_green('                 The popular game show in your command line!                 ')
end

# Opening splash screen / title card
def splash_screen
  print_logo

  # Instructions
  puts
  puts $pastel.italic('How to play:')
  puts
  puts $pastel.italic('  1. You will first draw 9 random letters (a mix of vowels and consonants)')
  puts $pastel.italic('  2. Enter the longest possible word using the drawn letters.')
  puts $pastel.italic('  3. Score more points for longer words.')
  puts $pastel.italic('  4. Remember, you only have 30 seconds to play a word!')
  puts

  # Show WOTD if the command line argument was input
  word_of_the_day if $wotd

  puts $divider
  puts

  prompt = TTY::Prompt.new
  prompt.keypress($pastel.green('Press key any key to continue...'))
end

# Check for command line arguments
def check_argv
  ARGV.each do |a|
    case a
    # Display Word of the Day
    when 'wotd'
      $wotd = true
    # Enable unlimited timer mode
    when 'notimer'
      $play_time = 'notimer'
    end
  end

  # After reading arguments, clear them so that we can read user input with 'gets'
  ARGV.clear
end

# Get the word of the day from: https://www.dictionary.com/e/word-of-the-day/
def word_of_the_day
  # Subtitle
  puts $pastel.dim.black.on_yellow('                               WORD OF THE DAY                               ')
  puts

  begin
    # Go to the word of the day page on dictionary.com
    url = 'https://www.dictionary.com/e/word-of-the-day/'

    # Scrape the HTML of the page using Nokogiri
    document = Nokogiri::HTML(URI.open(url))

    # Print the date using the CSS class
    puts $pastel.yellow(document.at_css('.otd-item-headword__date div').to_str)
    puts

    # Print the word using the CSS class
    puts $pastel.yellow.bold.underline(document.at_css('.otd-item-headword__word h1').to_str.upcase)
    puts

    # Print the definition using the CSS class
    puts WordWrap.ww(
      $pastel.dim.yellow.italic(document.at_css('.otd-item-headword__pos :nth-child(2)').to_str.strip.gsub(/\s+/,
                                                                                                           ' ')), 85
    )
    puts

    # Reference
    puts $pastel.yellow('- from Dictionary.com')
    puts
  rescue SocketError, Net::ReadTimeout => e
    error_text = "Sorry, Dictionary.com could not be reached to obtain the Word of the day.\nPlease check your connection and try again.\n\n"
    error_message('NETWORK ERROR', error_text, e)
  end
end

# Generate the pools of vowels and consonants
# The frequency of each letter is obtained from: http://www.thecountdownpage.com/letters.htm
# A string is created by multiplying each letter by their frequency, and then split into an array
def create_letter_pools
  $vowels = (('A ' * 15) + ('E ' * 21) + ('I ' * 13) + ('O ' * 13) + ('U ' * 5)).split
  $consonants = (('B ' * 2) + ('C ' * 3) + ('D ' * 6) + ('F ' * 2) + ('G ' * 3) +
                  ('H ' * 2) + ('J ' * 1) + ('K ' * 1) + ('L ' * 5) + ('M ' * 4) +
                  ('N ' * 8) + ('P ' * 4) + ('Q ' * 1) + ('R ' * 9) + ('S ' * 9) +
                  ('T ' * 9) + ('V ' * 1) + ('W ' * 1) + ('X ' * 1) + ('Y ' * 1) +
                  ('Z ' * 1)).split

  # Shuffle the pools
  $vowels.shuffle!
  $consonants.shuffle!
end

# Print the chosen letters
def display_letters
  # Split the string, add spaces, join the string again
  puts
  print ' ' * 28
  puts $pastel.bold.white.on_blue(' ' + ($scrambled_word.split('').map { |c| c + ' ' }).join)
  puts
end

# Centre align text
def centre_text(text, width)
  space_needed = ((width - text.length) / 2).to_i
  space_needed = 0 if space_needed < 0
  (' ' * space_needed) + text + (' ' * space_needed)
end

# The letter picking loop/process
def pick_letters
  $scrambled_word = ''

  # Player must choose 9 letters (3 vowels and 4 consonants are a must)
  i = 9
  vowel_num = 3
  cons_num = 4

  while i > 0
    system 'clear'

    print_logo

    choose_text = ''

    # Display how many more vowels & consonants need to be picked
    choose_text += " #{$pastel.green.bold(vowel_num)} more vowels." if vowel_num > 0

    choose_text += " #{$pastel.green.bold(cons_num)} more consonants." if cons_num > 0

    choose_text = ' Please pick:' + choose_text if choose_text.length > 0

    puts
    puts centre_text(("You must choose #{$pastel.green.bold(i)} more letters." + choose_text), $screen_width)

    display_letters

    # If the remaining letters to be picked equal the remaining vowels to be picked
    # then automatically pick the remaining vowels
    if i <= vowel_num
      $scrambled_word += $vowels.shift
      vowel_num -= 1
      sleep(0.2) # slow the program down to see the letters being picked automatically

    # Same with the consonants
    elsif i <= cons_num
      $scrambled_word += $consonants.shift
      cons_num
      sleep(0.2)

    else # Ask player what letter they would like

      prompt = TTY::Prompt.new
      choice = prompt.select('Would you like a vowel or consonant?', %w[Vowel Consonant])

      if choice == 'Vowel'

        # Draw the first vowel off the pile and place in the scrambled word
        # A space is added before the letter for formatting purposes
        $scrambled_word += $vowels.shift

        vowel_num -= 1
      else
        # Draw the first consonant off the pile and place in the scrambled word
        # A space is added before the letter for formatting purposes
        $scrambled_word += $consonants.shift
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

    begin
        player_word = player_word.split('')
        letter_pool = letter_pool.split('')

        player_word.each do |c|
            if letter_pool.include?(c)
            letter_pool.delete_at(letter_pool.index(c))
            else
            valid = false
            end
        end
    rescue StandardError => e
        error_text = 'Sorry, an error occurred while checking your input.'
        error_message('ERROR', error_text, e)
    end

  valid
end

# Allow the player to input words within a time limit --> Returns a valid word if entered by the player
def play_round
  if $play_time != 'notimer'
    # Code will be interrupted after 30 seconds
    timer = Timeout.timeout($play_time) do
      return input_word
    end
  else
    input_word
  end
rescue Timeout::Error
  puts
  puts $pastel.bold.white.on_red(centre_text('TIME IS UP!  NO POINTS SCORED', $screen_width + 2))
  puts

  ''
rescue StandardError => e

  error_message('SORRY! AN HAS ERROR OCCURRED', "", e)

  ''
end

# Ask the player to enter a word and check its validity
def input_word
  message = ''

  # Timer setup
  start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  while true

    system 'clear'
    print_logo

    puts
    puts centre_text('Try and find the longest possible word. Using each letter only ONCE.', $screen_width)

    display_letters

    # Calculate and display the time remaining
    if $play_time != 'notimer'
      time_left = ($play_time - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time)).ceil.to_i
      puts centre_text("------- You have less than #{time_left}s remaining! -------", $screen_width)
    else
      puts centre_text('------- UNLIMITED TIME MODE -------', $screen_width)
    end

    # Print a message if the previous word entered is invalid
    puts message

    print 'Enter a word: '

    # Remove all whitespace and brackets
    word = gets.chomp.gsub(/\s+/, '').upcase

    # Check if word is correct using gem & if only available letters are used
    if word.correct? && compare_word_arrays(word, $scrambled_word) && word != ''

      puts
      print $pastel.bold.white.on_green((' ' + word + ' ').upcase.to_s)
      print ' is valid and scores '
      puts $pastel.green.bold("#{score(word)} points!")
      puts

      return word
    else
      message = "\n" + $pastel.white.bold.on_red((' ' + word + ' ').upcase.to_s) + " is invalid. Try another word.\n\n"
    end
  end
end

# Get the definition of 'word' from: https://www.dictionary.com/e/word-of-the-day/
def define(word)
  # Go to the word page on dictionary.com
  url = 'https://www.dictionary.com/browse/' + word

  # Scrape the HTML of the page using Nokogiri
  document = Nokogiri::HTML(URI.open(url))

  # Search for the definition by finding the element where value=1 in the HTML code.
  # This denotes the first definition
  document.at_css('[value="1"]').to_str.capitalize
rescue SocketError, Net::ReadTimeout => e
    error_text = "Sorry, Dictionary.com could not be reached to find a definition.\nPlease check your connection and try again.\n\n"
    error_message('NETWORK ERROR', error_text, e)
  return '' # Return an empty string in the case of a Network error
rescue StandardError
  'Sorry, a definition could not be found.' # Return an apology if a definition could not be found
end

# Score a word
def score(word)
  # One point for each letter used
  value = word.length

  # Words using all 9 letters score 18
  value = 18 if value == 9

  $scores << value
  value
end

# The best possible answer that could be played is shown to the player, along with a definition
def best_word
  # Subtitle
  puts $pastel.dim.black.on_yellow('                              DICTIONARY CORNER                              ')

  puts
  puts centre_text('Searching dictionary for best playable word:', $screen_width)

  # uses all the letters -> need to create function that iterates though different combinations
  i = 9

  # Find the best possible words and show a progress bar
  $bar.reset
  response = $bar.iterate($find_word, 15).to_a.join

  # Limit the best words to only 4
  $best_words = $best_words.sample(4) if $best_words.length > 4

  # shuffle the words so no longer alphabetical
  $best_words.shuffle!

  # Find and display the definition of the top word.
  define_word = $best_words[0]
  $best_words = $best_words.drop(1)

  puts
  puts $pastel.yellow.bold.underline(define_word.upcase) # Print the word
  puts
  puts WordWrap.ww($pastel.italic.dim.yellow(define(define_word)), 85) # Print the definition (wrapping the text nicely)
  puts

  # Reference
  puts $pastel.yellow('- from Dictionary.com')
  puts

  if $best_words.length > 0
    puts
    print 'Other possible word(s): '
    print $best_words.join(', ')
    puts
  end

  puts
  puts $divider
  puts
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

# Display the player score / stats
def player_stats(word)
    begin
        $best_played_word = word if word.length > $best_played_word.length
        total_score = $scores.sum
        average_score = (total_score.to_f / $scores.size).round(2)

        puts $divider
        print 'Total Score: ' + $pastel.green.bold(total_score.to_s)
        print "\t  Average Score: " + $pastel.green.bold(average_score.to_s)
        puts  "\t Best Word Played: " + $pastel.green.bold($best_played_word)
        puts $divider
        puts
    rescue StandardError => e
        error_text = "Sorry, an error occurred while calculating your score.\n"
        error_message('ERROR', error_text, e)
    end
end

# Error message formatted
def error_message(label, text, error)
    puts $divider
    puts $pastel.bold.white.on_red(centre_text(label.to_s, $screen_width + 2))
    puts    
    puts text
    puts WordWrap.ww("Error: #{error}", 85)
    puts $divider
    puts
end

#                                       -MAIN PROGRAM-
# ===========================================================================================

system 'clear'

# Check for command line arguments
check_argv

# Display the Splash Screen / Title card
splash_screen

# Keep playing until player exits
while true

  # Create the letter pools that will be drawn from
  create_letter_pools

  # Player draws letters
  pick_letters

  # Player can play their word which is saved as a variable
  word = play_round

  # Display the score and statistics for the played word
  player_stats(word)

  # Slight delay before finding the best word
  sleep(1.0)

  # The best playable word is generated and displayed
  best_word

  # Play again?
  prompt = TTY::Prompt.new
  choice = prompt.select('Would you like to play again?', %w[Yes No])
  puts "\n\n"
  break if choice == 'No'

end
