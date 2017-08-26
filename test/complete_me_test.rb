require "minitest"
require "minitest/emoji"
require "minitest/autorun"

require "./test/test_helper"
require "./lib/complete_me"

class CompleteMeTest < Minitest::Test

  def test_complete_me_class_exists
    completion = CompleteMe.new()

    assert_instance_of CompleteMe, completion
  end

  def test_insert_inserts_word_into_compelete_me_trie
    completion = CompleteMe.new()

    completion.insert()
  end

  def test_suggest_returns_array_of_suggested_words_based_on_provided_prefix
    skip

    assert_equal ["Insert test array"], completion.suggest('pi')
  end


end
