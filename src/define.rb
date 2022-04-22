require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'artii'
require 'pastel'

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
        begin
            # Go to the word of the day page on dictionary.com
            url = 'https://www.dictionary.com/e/word-of-the-day/'

            # Scrape the HTML of the page using Nokogiri
            document = Nokogiri::HTML(URI.open(url))
    
            # Search for the definition by finding the element where value=1 in the HTML code.
            # This denotes the first definition
            # return document.at_css('[value="1"]').to_str.capitalize

            # Print the date using the CSS class
            puts document.at_css(".otd-item-headword__date div").to_str

            # Print the word using the CSS class
            puts document.at_css(".otd-item-headword__word h1").to_str.downcase

            puts "------------------------------------------"

            # Print the definition using the CSS class
            puts document.at_css(".otd-item-headword__pos p").to_str.strip.gsub(/\s+/, ' ')
            puts document.at_css(".otd-item-headword__pos :nth-child(2)").to_str.strip.gsub(/\s+/, ' ')



        rescue
            puts "Sorry, a definition could not be found."
        end
end

def splash_screen

    # ASCII Banner art
    pastel = Pastel.new
    a = Artii::Base.new :font => 'ogre'
    puts pastel.bold.white.on_blue(a.asciify('   c o u n t d o w n   '))

    # Subtitle
    puts pastel.white.black.on_green("                 The popular game show in your command line!                 ")

    # Instructions
    puts
    puts "How to play:"
    puts
    puts "  1. You will first draw 9 random letters (a mix of vowels and consonants)"
    puts "  2. Enter the longest possible word using the drawn letters."
    puts "  3. Score more points for longer words."
    puts "  4. Remember, you only have 30 seconds to play a word!"
    puts

end



system 'clear'

splash_screen
word_of_the_day

# print "Please enter a word: "

# word = gets.chomp
# puts define(word)
