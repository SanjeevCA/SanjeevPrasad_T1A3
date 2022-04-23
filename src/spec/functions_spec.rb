require 'rspec'
# require_relative '../countdown.rb'

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
