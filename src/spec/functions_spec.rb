require 'rspec'
require 'rword'  # Generate best words from the scrambled letters
require 'ru_bee' # Checking user input words for misspellings


# Check to see if the user used only the available letters
def compare_word_arrays(player_word, letter_pool)

    valid = true
    
    player_word = player_word.split("")
    letter_pool = letter_pool.split("")

    player_word.each {|c|
        
        if letter_pool.include?(c)
            letter_pool.delete_at(letter_pool.index(c))
        else
            valid = false
        end
    }

    return valid
end

# Find the best word from a scramble of letters
# A simplified version of the function used in the application
# The expanded version makes use of progress bars and other formatting etc.
def best_word(word)

    # setup variables
    best_words = []

    # Find possible words using all possible letters and then decrement
    i = word.length

    while i > 0

        # Gem returns an array of possible words of length i
        best_words = Rword.generate(word, i, true)

        # If words are generated
        if best_words.length > 0 
            break
        else
            # If not, try find a smaller word
            i -= 1
        end
    end

    # Limit the best words to only 4
    if best_words.length > 4                
        best_words = best_words.sample(4)
    end
    return best_words.length

end

# See if the user is playing with only the available letters
describe "Compare words and return true if the characters in the first word exist in the second word" do

    it "Return true if the first word uses characters from the second" do
        expect(compare_word_arrays("HELLO","LLHEO")).to be(true)
    end

    it "Return true if characters exist but not all are used from the second word" do
        expect(compare_word_arrays("WORLD","DEWODAXLRK")).to be(true)
    end

    it "Return false if a character is used more than once" do
        expect(compare_word_arrays("MOON","MONDAY")).to be(false)
    end

    it "Return false if character doesn't exist in the second word" do
        expect(compare_word_arrays("ALPHA","OIPEKLE")).to be(false)
    end

end

# See if the input words are spelled correctly using 'ru_bee' gem
describe "Is the input word a correctly spelled, English word?" do

    it "A correctly spelled word should return true" do
        expect(("hello").correct?).to be(true)
    end

    it "An incorrectly spelled word should return false" do
        expect(("wlrd").correct?).to be(false)
    end

    it "Unexpected characters should return false" do
        expect(("@ppl3s!").correct?).to be(false)
    end

end

# See if words are being generated properly using the 'rword' gem
describe "Using the 'rword' gem, generate a list of words from scrambled letters" do

    it "Return more than 1 word, generated from the scrambled letters" do
        expect(best_word("auplechts")).to be > 0
    end

    it "Do not return more than 4 words, in a case where many words are generated" do
        expect(best_word("eldsas")).to be <= 4
    end

    it "Return a list using only valid letters, ignoring any non-letter characters" do
        expect(best_word("ad3etpl#")).to be > 0
    end

end