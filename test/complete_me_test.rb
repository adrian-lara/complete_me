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

  def test_insert_inserts_single_word
    cm.insert('me')
    assert_equal 1, cm.count
  end

  def test_insert_creates_a_node_for_each_letter_of_a_word
    cm.insert('me')

    assert_instance_of Node, cm.root.children['m']
    assert_instance_of Node, cm.root.children['m'].children['e']
  end

  def test_insert_indicates_an_end_of_a_word_at_the_node_containing_the_last_char_as_a_key
    cm.insert('me')

    assert true, cm.root.children['m'].end?
  end

  def test_count_starts_at_zero
    assert_equal 0, cm.count
  end

  def test_count_returns_number_of_words_in_library_of_words_on_separate_branches
    cm.insert('me')
    cm.insert('hi')

    assert_equal 2, cm.count
  end

  def test_count_returns_number_of_words_in_library_of_word_sharing_branches
    cm.insert('me')
    cm.insert('meme')
    cm.insert('memes')

    assert_equal 3, cm.count
  end

  def test_count_doesnt_double_count_a_word_that_was_inserted_twice
    cm.insert('me')
    cm.insert('me')

    assert_equal 1, cm.count
  end

  def test_populate_inserts_each_word_on_a_line_within_a_list
    cm.populate("pizza\ndog\ncat")
    assert_equal 3, cm.count
  end

  def test_suggest_returns_an_array_of_a_single_word_given_a_prefix_of_that_word
    cm.insert('pizza')
    result = ['pizza']

    assert_equal result, cm.suggest("piz")
  end

  def test_suggest_returns_an_array_of_words_that_begin_with_given_prefix
    cm.insert('me')
    cm.insert('meme')
    cm.insert('pizza')
    cm.insert('pizzeria')
    cm.insert('pizzicato')
    result = ['pizzicato', 'pizzeria', 'pizza']

    assert_equal result, cm.suggest("piz")
  end

  def test_suggest_returns_all_words_if_prefix_is_empty_string
    cm.insert('me')
    cm.insert('meme')
    cm.insert('pizza')
    cm.insert('pizzeria')
    cm.insert('pizzicato')
    result = ['pizzicato', 'pizzeria', 'pizza', 'me', 'meme']

    assert_equal result, cm.suggest("")
  end

  def test_select_can_save_a_selection_from_a_prefix
    cm.select('pi','pizza')

    assert ['pizza'], cm.suggest('pi')
  end

  def test_select_can_save_multiple_selections_from_a_single_prefix
    cm.select('pi','pizza')
    cm.select('pi','pizzle')

    assert ['pizza', 'pizzle'], cm.suggest('pi')
  end

  def test_select_saves_suggestions_only_according_specific_prefixes
    cm.select('pi','pizza')
    cm.select('pizz','pizzle')

    assert ['pizza'], cm.suggest('pi')
    assert ['pizzle'], cm.suggest('pizz')
  end

  def test_suggest_returns_ordered_array_according_to_most_to_least_selected
    cm.insert('pizza')
    cm.insert('pizzeria')
    cm.insert('pizzicato')
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzicato")
    result = ['pizzeria', 'pizzicato', 'pizza']

    assert_equal result, cm.suggest("piz")
  end

  def test_find_node_returns_node_of_accessed_by_last_character_of_given_prefix
    cm.insert('meal')

    assert_equal cm.root.children['m'].children['e'], cm.find_node('me')
  end

  def test_find_node_returns_nil_if_prefix_path_doesnt_exist
    cm.insert('pizza')
    cm.insert('pizzeria')

    assert_nil cm.find_node('m')
  end

  def test_generate_suggestions_returns_empty_array_if_no_words_in_library_begin_with_prefix
    cm.insert('pizza')
    cm.insert('pizzeria')

    assert [], cm.generate_suggestions('m')
  end

  def test_generate_suggestions_returns_an_array_of_words_in_the_library_beginning_with_a_given_prefix
    cm.insert('pizza')
    cm.insert('pizzle')
    cm.insert('pine')

    assert ['pizza', 'pizzle', 'pine'], cm.generate_suggestions('pi')
  end

  def test_order_suggestions_returns_ordered_array_according_to_most_to_least_selected
    cm.insert('pizza')
    cm.insert('pizzeria')
    cm.insert('pizzicato')
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzicato")
    piz_suggestions = ['pizza', 'pizzeria', 'pizzicato']
    result = ['pizzeria', 'pizzicato', 'pizza']

    assert_equal result, cm.order_suggestions("piz", piz_suggestions)
  end

  def test_populate_from_csv_inserts_300_unique_denver_addresses
    cm.populate_from_csv('./test/data/addresses_first_300.csv')

    assert_equal 300, cm.count
  end

  def test_populate_from_csv_can_handle_306009_denver_addresses
    skip
    cm.populate_from_csv('./test/data/addresses.csv')
  end

end
