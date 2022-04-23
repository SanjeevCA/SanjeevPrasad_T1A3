require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'artii'
require 'pastel'
require 'tty-prompt'
require 'word_wrap'

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


def word_of_the_day

    # Subtitle
    puts $pastel.bold.black.on_yellow("                               WORD OF THE DAY                               ")
    puts

        begin
            # Go to the word of the day page on dictionary.com
            url = 'https://www.dictionary.com/e/word-of-the-day/'

            # Scrape the HTML of the page using Nokogiri
            document = Nokogiri::HTML(URI.open(url))
    
            # Search for the definition by finding the element where value=1 in the HTML code.
            # This denotes the first definition
            # return document.at_css('[value="1"]').to_str.capitalize

            # Print the date using the CSS class
            puts $pastel.yellow(document.at_css(".otd-item-headword__date div").to_str)
            puts

            # Print the word using the CSS class
            puts $pastel.yellow.bold.underline(document.at_css(".otd-item-headword__word h1").to_str.upcase)
            puts

            # Print the definition using the CSS class
            # puts $pastel.yellow(document.at_css(".otd-item-headword__pos p").to_str.strip.gsub(/\s+/, ' '))
            puts WordWrap.ww($pastel.dim.yellow.italic(document.at_css(".otd-item-headword__pos :nth-child(2)").to_str.strip.gsub(/\s+/, ' ')), 85)
            puts


        rescue
            puts "Sorry, Word of the Day could not be obtained."
        end
end

# Opening splash screen / title card
def splash_screen

    # ASCII Banner art    
    a = Artii::Base.new :font => 'ogre'
    puts $pastel.bold.white.on_blue(a.asciify('   c o u n t d o w n   '))

    # Subtitle
    puts $pastel.bold.white.on_green("                 The popular game show in your command line!                 ")

    # Instructions
    puts
    puts $pastel.italic("How to play:")
    puts
    puts $pastel.italic("  1. You will first draw 9 random letters (a mix of vowels and consonants)")
    puts $pastel.italic("  2. Enter the longest possible word using the drawn letters.")
    puts $pastel.italic("  3. Score more points for longer words.")
    puts $pastel.italic("  4. Remember, you only have 30 seconds to play a word!")
    puts

end

# Check for command line arguments
def check_argv

    ARGV.each do|a|     
        case a
        when "wotd"
            word_of_the_day
        when "notimer"
            # puts "NO TIMER MODE ENABLED"
        end
    end

end

$pastel = Pastel.new


system 'clear'

splash_screen
check_argv

puts "=============================================================================\n\n"
# puts $pastel.green("Press any key to continue...")
prompt = TTY::Prompt.new
prompt.keypress($pastel.green("Press key any key to continue..."))

# word_of_the_day

# print "Please enter a word: "

# word = gets.chomp
# puts define(word)
