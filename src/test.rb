# Do not display deprecation warning messages from gems.
original_verbosity = $VERBOSE
$VERBOSE=nil

require 'ru_bee'
require 'rword'
require 'colorize'
require 'oxford_dictionary'
require 'dictionary_lookup'
require 'meaning'
require 'word_wrap'


client = OxfordDictionary::Client.new(app_id: 'f4feab1e', app_key: 'e09623e3bd0b048c5ea3bbf90f9cec4c')
client = OxfordDictionary.new(app_id: 'f4feab1e', app_key: 'e09623e3bd0b048c5ea3bbf90f9cec4c')

puts " valid ".black.on_light_green
print "Enter a word: "

word = gets.chomp.gsub(/\s+/, '')

pp word

# Check if word is correct using gem
puts word.correct?

# results = DictionaryLookup::Base.define(word)

# puts results.first.denotation.capitalize

cam = Meaning::MeaningLab.new word

definition = (cam.dictionary[:definitions]).shift
# definition = definition.gsub(/\n\s+/, " ")
definition = definition.gsub("\n", ' ').squeeze(' ')


WordWrap.ww definition, 2
pp definition


# pp (((cam.dictionary[:definitions]).shift).strip).capitalize


# entry = client.entry(word: word, dataset: 'en-gb', params: {})
# puts entry


# uses all the letters -> need to create function that iterates though different combinations

# i = 9

# while i >= 2
#     # Generate the words and display the longest ones
#     # Maybe randomly pick a long word to display?
#     best_words = Rword.generate(word, i, true)

#     if best_words.length > 0
#         pp best_words
#         break
#     else
#         i -= 1
#     end    
# end

