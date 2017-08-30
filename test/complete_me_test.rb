require "./test/test_helper"

require "minitest"
require "minitest/emoji"
require "minitest/autorun"

require "./lib/complete_me"


class CompleteMeTest < Minitest::Test
  attr_reader :cm, :root
  def setup
    @cm = CompleteMe.new
    @root = cm.root
  end

  def test_insert_inserts_single_word
    cm.insert('me')
    assert_equal 1, cm.count
  end

  def test_insert_wont_insert_empty_string
    refute cm.insert('')
    refute root.end?
    assert_equal 0, cm.count
  end

  def test_insert_creates_a_node_for_each_letter_of_a_word
    cm.insert('me')
    assert_instance_of Node, root.children['m']
    assert_instance_of Node, root.children['m'].children['e']
  end

  def test_insert_works_with_other_characters
    crazy_word = "aAzZ19 \t\n!@{$%^#&*()}#|~`"
    cm.insert(crazy_word)
    assert_equal [ crazy_word ], cm.suggest('')
  end

  def test_insert_marks_last_node_of_word_as_end
    cm.insert('me')
    assert root.children['m'].children['e'].end?
  end

  def test_insert_is_case_sensitive
    cm.insert 'A'
    cm.insert 'a'

    assert_equal 2, cm.count
    refute root.children['A'].equal?(root.children['a'])
  end

  def test_count_is_zero_for_empty_trie
    assert_equal 0, cm.count
  end

  def test_counts_inserted_words
    cm.populate("pizza\naardvark\nzombies\na\nxylophones")
    assert_equal 5, cm.count
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

  def test_count_doesnt_double_count_a_word_inserted_twice
    cm.insert('me')
    cm.insert('me')

    assert_equal 1, cm.count
  end

  def test_words_using_returns_the_number_of_words_within_a_particular_node
    cm.insert('me')
    cm.insert('meme')
    cm.insert('memes')
    mem_node = cm.root.children['m'].children['e'].children['m']

    assert_equal 2, cm.words_using(mem_node)
  end

  def test_populate_inserts_each_word_on_a_line_within_a_list
    cm.populate("pizza\ndog\nit")
    assert_equal 3, cm.count
    assert_instance_of Node, root.children['i'].children['t']
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

    assert_equal root.children['m'].children['e'], cm.find_node('me')
  end

  def test_find_node_returns_nil_if_prefix_path_doesnt_exist
    cm.insert('pizza')
    cm.insert('pizzeria')

    assert_nil cm.find_node('m')
  end

  def test_generate_suggestions_returns_empty_array_if_no_words_in_library_begin_with_prefix
    cm.insert('pizza')
    cm.insert('pizzeria')

    assert_equal [], cm.generate_suggestions('m')
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

  def test_populate_from_csv_inserts_300_denver_addresses
    cm.populate_from_csv('./test/data/addresses_first_300.csv')

    assert_equal 300, cm.count
  end

  def test_delete_removes_only_word
    cm.insert("AA")
    cm.delete("AA")

    assert_nil root.children["A"]
  end

  def test_delete_removes_end_status_of_intermediate_node
    cm.populate("A\nAAA")
    cm.delete("A")

    deleted_word_node = root.children["A"]
    descendent_word_node = deleted_word_node.children["A"].children["A"]

    refute deleted_word_node.end?
    assert_instance_of Node, descendent_word_node

    assert_equal 1, cm.count
  end

  def test_delete_removes_leaf_node_ancestors_back_to_ending_node
    cm.populate("A\nAAA")
    cm.delete("AAA")

    ending_ancestor = root.children["A"]

    assert_instance_of Node, ending_ancestor
    assert ending_ancestor.end?
    assert_nil ending_ancestor.children["A"]

    assert_equal 1, cm.count
  end

  def test_delete_removes_leaf_node_ancestors_back_to_branching_node
    cm.populate("AAA\nAbb")
    cm.delete("Abb")

    branching_ancestor = root.children['A']
    remaining_cousin = branching_ancestor.children['A'].children['A']

    assert_nil branching_ancestor.children["B"]
    assert_instance_of Node, remaining_cousin

    assert_equal 1, cm.count
  end

  def test_delete_removes_word_cousined_only_through_root
    cm.populate("AA\nBB")
    cm.delete("BB")

    remaining_cousin = root.children["A"].children["A"]

    assert_nil root.children["B"]
    assert_instance_of Node, remaining_cousin

    assert_equal 1, cm.count
  end

  def test_delete_does_nothing_if_word_is_not_present
    cm.insert('AA')

    cm.delete('AAA')
    cm.delete('A')
    cm.delete('B')
    cm.delete('')

    assert_instance_of Node, root.children['A'].children['A']

    assert_equal 1, cm.count
  end

  def test_delete_returns_true_if_word_was_deleted
    cm.populate("pizza\npardva\npardvark\npard\nfoo")
    assert cm.delete('pard')
    assert cm.delete('pardvark')
    assert cm.delete('pardva')
    assert cm.delete('pizza')
    assert cm.delete('foo')
  end

  def test_delete_returns_false_if_no_word_was_deleted
    cm.insert('AA')

    refute cm.delete('AAA')
    refute cm.delete('A')
    refute cm.delete('B')
    refute cm.delete('')
  end


  def test_all_features_with_large_dataset
    long_running_test!

    dictionary = File.read("/usr/share/dict/words")
    cm.populate(dictionary)
    cm.select('me','meet')
    cm.select('me','meet')
    cm.select('me','meet')
    cm.select('me','meet')
    cm.select('me','meant')
    cm.select('me','me')
    cm.select('me','me')

    assert_equal ['meet', 'me', 'meant'], cm.suggest('me')[0..2]

    total = cm.count
    cm.delete('me')
    new_total = cm.count

    assert_equal total - 1, new_total
    assert_equal ['meet', 'meant'], cm.suggest('me')[0..1]
  end

  def test_all_features_with_very_large_data_set
    long_running_test!

    cm.populate_from_csv('./test/data/addresses.csv')
    cm.populate(File.read('./test/data/medium.txt'))
    cm.populate(File.read('/usr/share/dict/words'))

    assert cm.suggest('2525 W').include? '2525 Wewatta Way Unit 165'

    cm.select('2525 W', '2525 Wewatta Way Unit 165')
    assert_equal '2525 Wewatta Way Unit 165', cm.suggest('2525 W').first

    cm.delete('2525 Wewatta Way Unit 165')
    refute cm.suggest('2525 W').include? '2525 Wewatta Way Unit 165'

    cm.insert('2525 Wewatta Way Unit 165')
    assert cm.suggest('2525 W').include? '2525 Wewatta Way Unit 165'

    assert_equal cm.count, cm.suggest('').length
  end

  def long_running_test!
    skip unless ENV['run_long_tests'] == 'true'
  end
end
