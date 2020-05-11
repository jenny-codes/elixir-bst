defmodule ElixirBstTest do
  use ExUnit.Case
  doctest Bst

  describe "new/1" do
    test "with one element" do
      assert %Bst{data: 1} == Bst.new(1)
    end

    test "with a list" do
      assert %Bst{data: 1} == Bst.new([1])
      assert %Bst{data: 1, right: %Bst{data: 2}} == Bst.new([1, 2])
    end
  end

  describe "search/3" do
    test "returns the data if it exists" do
      tree = %Bst{
        data: {3, :value3},
        left: %Bst{data: {1, :value1}, right: %Bst{data: {2, :value2}}},
        right: %Bst{data: {5, :value5}, left: %Bst{data: {4, :value4}}}
      }

      comparator = &(&1 - elem(&2, 0))

      assert {4, :value4} == Bst.search(tree, 4, comparator)
    end

    test "returns nil if data does not exist in the tree" do
      tree = %Bst{
        data: {3, :value3},
        left: %Bst{data: {1, :value1}, right: %Bst{data: {2, :value2}}},
        right: %Bst{data: {5, :value5}, left: %Bst{data: {4, :value4}}}
      }

      comparator = &(&1 - elem(&2, 0))

      assert nil == Bst.search(tree, -1, comparator)
    end
  end

  describe "insert/3" do
    test "from scratch" do
      assert %Bst{data: 1} == Bst.insert(nil, 1)
    end

    test "greater value goes to right node of tree" do
      existing_tree = %Bst{data: 1}
      expected_tree = %Bst{data: 1, right: %Bst{data: 2}}
      assert expected_tree == Bst.insert(existing_tree, 2)
    end

    test "greater value goes to right node of tree, multiple layers" do
      existing_tree = %Bst{data: 1, right: %Bst{data: 2}}
      expected_tree = %Bst{data: 1, right: %Bst{data: 2, right: %Bst{data: 3}}}
      assert expected_tree == Bst.insert(existing_tree, 3)
    end

    test "lesser value goes to right node of tree" do
      existing_tree = %Bst{data: 1}
      expected_tree = %Bst{data: 1, left: %Bst{data: 0}}
      assert expected_tree == Bst.insert(existing_tree, 0)
    end

    test "lesser value goes to right node of tree, multiple layers" do
      existing_tree = %Bst{data: 1, left: %Bst{data: 0}}
      expected_tree = %Bst{data: 1, left: %Bst{data: 0, left: %Bst{data: -1}}}
      assert expected_tree == Bst.insert(existing_tree, -1)
    end

    test "consecutive inserts" do
      tree =
        Bst.insert(nil, 3)
        |> Bst.insert(2)
        |> Bst.insert(1)
        |> Bst.insert(4)

      expected_tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4}
      }

      assert expected_tree == tree
    end

    test "with custom comparator" do
      comparator = &(elem(&1, 0) - elem(&2, 0))

      existing_tree = %Bst{data: {1, :dontcare}}
      expected_tree = %Bst{data: {1, :dontcare}, right: %Bst{data: {2, :betterwork}}}

      assert expected_tree == Bst.insert(existing_tree, {2, :betterwork}, comparator)
    end
  end

  describe "to_list/2" do
    test "returns an empty list if tree is nil" do
      assert [] == Bst.to_list(nil)
    end

    test "returns the data of tree, one element" do
      tree = %Bst{data: 1}

      assert [1] == Bst.to_list(tree)
    end

    test "returns the data of tree, two elements" do
      tree = %Bst{data: 1, right: %Bst{data: 2}}

      assert [1, 2] == Bst.to_list(tree)
    end

    test "returns the data of tree, three elements" do
      unbalanced_tree = %Bst{data: 1, right: %Bst{data: 2, right: %Bst{data: 3}}}
      balanced_tree = %Bst{data: 2, right: %Bst{data: 3}, left: %Bst{data: 1}}

      assert [1, 2, 3] == Bst.to_list(unbalanced_tree)
      assert [1, 2, 3] == Bst.to_list(balanced_tree)
    end

    test "with a multi-layer tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4, right: %Bst{data: 5}}
      }

      assert [1, 2, 3, 4, 5] == Bst.to_list(tree)
    end

    test "with yet another multi-layer tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      assert [1, 2, 3, 4, 5] == Bst.to_list(tree)
    end

    test "with transformer" do
      tree = %Bst{
        data: {3, :value3},
        left: %Bst{data: {1, :value1}, right: %Bst{data: {2, :value2}}},
        right: %Bst{data: {5, :value5}, left: %Bst{data: {4, :value4}}}
      }

      transformer = &elem(&1, 0)

      assert [1, 2, 3, 4, 5] == Bst.to_list(tree, transformer)
    end
  end

  describe "put/3" do
    test "replaces the old value with the new if value evaluates to same" do
      tree = %Bst{
        data: {3, :value3},
        left: %Bst{data: {1, :value1}, right: %Bst{data: {2, :value2}}},
        right: %Bst{data: {5, :value5}, left: %Bst{data: {4, :value4}}}
      }

      comparator = &(elem(&1, 0) - elem(&2, 0))

      expected_new_tree = %Bst{
        data: {3, :value3},
        left: %Bst{data: {1, :new_value1}, right: %Bst{data: {2, :value2}}},
        right: %Bst{data: {5, :value5}, left: %Bst{data: {4, :value4}}}
      }

      assert expected_new_tree == Bst.put(tree, {1, :new_value1}, comparator)
    end

    test "behaves like insert/2 if old value does not exist" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      expected_new_tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}, left: %Bst{data: -1}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      assert expected_new_tree == Bst.put(tree, -1)
    end
  end

  describe "delete/3" do
    test "with a one-node tree" do
      assert nil == Bst.new(1) |> Bst.delete(1)
    end

    test "with the leaf of a multi-node tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4, right: %Bst{data: 5}}
      }

      expected_tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4, right: nil}
      }

      assert expected_tree == Bst.delete(tree, 5)
    end

    test "with the branch of a multi-node tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4, right: %Bst{data: 5}}
      }

      expected_tree = %Bst{
        data: 3,
        left: %Bst{data: 1},
        right: %Bst{data: 4, right: %Bst{data: 5}}
      }

      assert expected_tree == Bst.delete(tree, 2)
    end

    # NOTE: The logic now is to use the right side as main branch.
    test "with the head of a multi-node tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 4, right: %Bst{data: 5}}
      }

      expected_tree = %Bst{
        data: 4,
        left: %Bst{data: 2, left: %Bst{data: 1}},
        right: %Bst{data: 5}
      }

      assert expected_tree == Bst.delete(tree, 3)
    end

    test "returns the same tree if element does not exist" do
      assert Bst.new(1) == Bst.new(1) |> Bst.delete(0)
    end

    test "with custom comparator" do
      comparator = fn new, orig ->
        String.length(new) - String.length(orig)
      end

      tree = %Bst{
        data: "333",
        left: %Bst{data: "22", left: %Bst{data: "1"}},
        right: %Bst{data: "4444", right: %Bst{data: "55555"}}
      }

      expected_tree = %Bst{
        data: "333",
        left: %Bst{data: "1"},
        right: %Bst{data: "4444", right: %Bst{data: "55555"}}
      }

      assert expected_tree == Bst.delete(tree, "22", comparator)
    end
  end

  describe "min/1" do
    test "return the minimum value of the tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      assert 1 == Bst.min(tree)
    end
  end

  describe "remove_min/2" do
    test "return a new BST with the minimum value removed" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      expected_min_removed_tree = %Bst{
        data: 3,
        left: %Bst{data: 2},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      assert expected_min_removed_tree == Bst.remove_min(tree)
    end
  end

  describe "max/1" do
    test "return the maximum value of the tree" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      assert 5 == Bst.max(tree)
    end
  end

  describe "remove_max/2" do
    test "return a new BST with the maximum value removed" do
      tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 5, left: %Bst{data: 4}}
      }

      expected_max_removed_tree = %Bst{
        data: 3,
        left: %Bst{data: 1, right: %Bst{data: 2}},
        right: %Bst{data: 4}
      }

      assert expected_max_removed_tree == Bst.remove_max(tree)
    end
  end
end
