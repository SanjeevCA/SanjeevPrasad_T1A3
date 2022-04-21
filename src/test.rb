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
require 'tty-progressbar'

# client = OxfordDictionary::Client.new(app_id: 'f4feab1e', app_key: 'e09623e3bd0b048c5ea3bbf90f9cec4c')
# client = OxfordDictionary.new(app_id: 'f4feab1e', app_key: 'e09623e3bd0b048c5ea3bbf90f9cec4c')

# puts " valid ".black.on_light_green
# print "Enter a word: "

# word = gets.chomp.gsub(/\s+/, '')

# pp word

# # Check if word is correct using gem
# puts word.correct?

# cam = Meaning::MeaningLab.new word

# definition = (cam.dictionary[:definitions]).shift
# # definition = definition.gsub(/\n\s+/, " ")
# definition = definition.gsub("\n", ' ').squeeze(' ')
# system 'clear'
# require 'timeout'
# require 'tty-progressbar'
# words = []
# begin
#     status = Timeout::timeout(5) {
#         # Something that should be interrupted if it takes more than 5 seconds...
#         while true
#             word = gets.chomp
#             words.push(word)
#             pp words
#         end
#     }
# rescue
#     puts '--------------------------------------------'
#     puts "TIME IS UP!"
#     puts '--------------------------------------------'
# end

# puts "press any key to continue..."
# gets

CONTENT_SIZE = 2048
CHUNK_SIZE = 255

# Dummy "long responding server"
def download_from_server(offset, limit)
  sleep(0.1)
  "<chunk #{offset}..#{offset + limit}>"
end

def download_finished?(position)
  position >= CONTENT_SIZE
end

downloader = Enumerator.new do |y|
  start = 0
  loop do
    y.yield(download_from_server(start, CHUNK_SIZE))
    start += CHUNK_SIZE
    raise StopIteration if download_finished?(start)
  end
end

# bar = TTY::ProgressBar.new("[:bar] :percent", total: CONTENT_SIZE)

# response = bar.iterate(downloader, CHUNK_SIZE).to_a.join

# puts response

# ---------------------------------------------------

require 'rword'
system 'clear'

$bar = TTY::ProgressBar.new("[:bar] :percent", total: 100)

print "Enter letters: "
scramble = gets.chomp

descrambler = Enumerator.new do |y|
    i = 9
    count = 0
    while i >= 2
        count += 1
        y.yield(count)
        best_words = Rword.generate(scramble, i, true)
        if best_words.length > 0 
            $bar.finish
            puts
            pp best_words
            break
        else
            i -= 1
        end
    end
end


response = $bar.iterate(descrambler, 20).to_a.join