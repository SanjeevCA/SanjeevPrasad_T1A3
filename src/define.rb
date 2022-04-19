require 'httparty'
require 'nokogiri'
require 'open-uri'




# system 'clear'
# puts "========================================================================="

# word = gets.chomp
# url = 'https://www.dictionary.com/browse/'+ word

# # Fetch and parse HTML document
# document = Nokogiri::HTML(URI.open(url))

# # Search for nodes by css
# # doc.css('id="top-definitions-section"').each do |link|
# #   puts link.content
# # end

# definition = document.at_css(".one-click-content").to_str.capitalize

# puts word
# puts %Q{"#{definition}"}

# puts "--------------------------------------"

# definition2 = document.at_css('[value="1"]').to_str.capitalize

# puts word
# puts %Q{"#{definition2}"}


def define(word)
    url = 'https://www.dictionary.com/browse/'+ word
    document = Nokogiri::HTML(URI.open(url))
    return document.at_css('[value="1"]').to_str.capitalize
end