require "./test/test_helper"

require "minitest"
require "minitest/emoji"
require "minitest/autorun"

require "./lib/complete_me"


class CompleteMeTest < Minitest::Test
  attr_reader :cm
  def setup
    @cm = CompleteMe.new
  end

  def test_starting_count
    assert_equal 0, cm.count
  end

  def test_counts_inserted_words
    insert_words(["pizza", "aardvark", "zombies", "a", "xylophones"])
    assert_equal 5, cm.count
  end

  def test_insert_creates_a_node_for_each_letter_of_a_word
    cm.insert('me')

    assert_instance_of Node, cm.root.children['m']
    assert_instance_of Node, cm.root.children['m'].children['e']
  end

  def test_insert_indicates_an_end_of_a_word_at_a_words_last_letter_node
    cm.insert('me')

    assert true, cm.root.children['m'].end?
  end

  def test_insert_inserts_single_word
    cm.insert("pizza")
    assert_equal 1, cm.count
  end

  def test_populate_inserts_multiple_words
    cm.populate("pizza\ndog\ncat")
    assert_equal 3, cm.count
  end

  def test_populate_inserts_medium_dataset
    cm.populate(medium_word_list)
    assert_equal medium_word_list.split("\n").count, cm.count
  end

  def test_populate_works_with_large_dataset
    cm.populate(large_word_list)
    assert_equal ["doggerel", "doggereler", "doggerelism", "doggerelist", "doggerelize", "doggerelizer"], cm.suggest("doggerel").sort
    cm.select("doggerel", "doggerelist")
    assert_equal "doggerelist", cm.suggest("doggerel").first
  end

  def test_selects_off_of_medium_dataset
    cm.populate(medium_word_list)
    cm.select("wi", "wizardly")
    assert_equal ["wizardly", "williwaw"], cm.suggest("wi")
  end

  def test_selects_are_prefix_specific
    cm.populate(large_word_list)
    cm.select("doggerel", "doggerelist")
    cm.select("dogger", "doggereler")
    assert_equal "doggerelist", cm.suggest("doggerel").first
    assert_equal "doggereler", cm.suggest("dogger").first
  end

  def test_suggests_off_of_small_dataset
    insert_words(["pizza", "aardvark", "zombies", "a", "xylophones"])
    assert_equal ["pizza"], cm.suggest("p")
    assert_equal ["pizza"], cm.suggest("piz")
    assert_equal ["zombies"], cm.suggest("zo")
    assert_equal ["a", "aardvark"], cm.suggest("a").sort
    assert_equal ["aardvark"], cm.suggest("aa")
  end

  def test_suggests_off_of_medium_dataset
    cm.populate(medium_word_list)
    assert_equal ["williwaw", "wizardly"], cm.suggest("wi").sort
  end

  def test_find_node_returns_node_of_last_character_of_given_prefix
    cm.insert('meal')

    assert_equal cm.root.children['m'].children['e'], cm.find_node('me')
  end

  def test_find_node_returns_nil_if_prefix_path_doesnt_exist
    assert_nil cm.find_node('m')
  end

  def test_order_suggestions_returns_ordered_array_according_to_most_to_least_selected
    cm.insert('pizza')
    cm.insert('pizzeria')
    cm.insert('pizzicato')
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzicato")
    piz_suggestions = cm.generate_suggestions("piz")
    result = ['pizzeria', 'pizzicato', 'pizza']

    assert_equal result, cm.order_suggestions("piz", piz_suggestions)
  end

  def test_populate_from_csv_inserts_300_denver_addresses
    cm.populate_from_csv('./test/addresses_first_300.csv')

    assert_equal 300, cm.count
  end

  def test_populate_from_csv_inserts_306009_denver_addresses
    cm.populate_from_csv('./test/addresses.csv')

    assert_equal 306009, cm.count
  end

  def insert_words(words)
    cm.populate(words.join("\n"))
  end

  def medium_word_list
    File.read("./test/medium.txt")
  end

  def large_word_list
    File.read("/usr/share/dict/words")
  end
end
