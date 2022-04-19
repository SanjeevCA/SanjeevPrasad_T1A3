require 'httparty'
require 'nokogiri'
require 'open-uri'

def define(word)

    # Go to the word page on dictionary.com
    url = 'https://www.dictionary.com/browse/'+ word

    # Scrape the HTML of the page using Nokogiri
    document = Nokogiri::HTML(URI.open(url))

    # Search for the definition by finding the element where value=1 in the HTML code.
    # This denotes the first definition
    return document.at_css('[value="1"]').to_str.capitalize
end