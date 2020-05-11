defmodule Bst do
  @enforce_keys [:data]
  defstruct [:data, :left, :right]

  @default_comparator &-/2

  @moduledoc """
  Elixir Implementation for Binary Search Tree.
  """

  # ----------------------------------------------
  # new/1

  def new(data) when is_list(data) do
    Enum.reduce(data, nil, fn datum, acc ->
      Bst.insert(acc, datum)
    end)
  end

  def new(data) do
    Bst.insert(nil, data)
  end

  # ----------------------------------------------
  # insert/2

  def insert(tree, new_data, comparator \\ @default_comparator) do
    insert_node(tree, %Bst{data: new_data}, comparator)
  end

  defp insert_node(nil, new_node, _comparator), do: new_node

  # TODO: Decide where equal values go to.
  defp insert_node(tree, new_node, comparator) do
    compare(tree.data, new_node.data, comparator, fn
      :is_gt -> %{tree | right: insert_node(tree.right, new_node, comparator)}
      :is_lt -> %{tree | left: insert_node(tree.left, new_node, comparator)}
      :is_eq -> %{tree | left: insert_node(tree.left, new_node, comparator)}
    end)
  end

  # ----------------------------------------------
  # delete/2

  def delete(tree, data, comparator \\ @default_comparator)

  def delete(nil, _data, _comparator), do: nil

  def delete(tree, data, comparator) do
    compare(tree.data, data, comparator, fn
      :is_gt -> %{tree | right: delete(tree.right, data, comparator)}
      :is_lt -> %{tree | left: delete(tree.left, data, comparator)}
      :is_eq -> remove_node(tree, comparator)
    end)
  end

  defp remove_node(%Bst{data: nil}, _comparator), do: nil
  defp remove_node(%Bst{right: nil, left: left}, _comparator), do: left
  defp remove_node(%Bst{right: right, left: nil}, _comparator), do: right

  # TODO: Choose side more garcefully.
  defp remove_node(%Bst{right: right, left: left}, comparator) do
    insert_node(right, left, comparator)
  end

  # ----------------------------------------------
  # to_list/1

  def to_list(tree) do
    extract_data(tree, [])
  end

  defp extract_data(nil, acc), do: acc

  defp extract_data(%Bst{data: data, right: nil, left: nil}, acc), do: [data | acc]

  defp extract_data(tree, acc) do
    extract_data(tree.right, acc) |> (fn acc -> extract_data(tree.left, [tree.data | acc]) end).()
  end

  # ----------------------------------------------
  # min & max operators

  def min(node) do
    if is_nil(node.left) do
      node.data
    else
      min(node.left)
    end
  end

  def remove_min(node, comparator \\ @default_comparator) do
    if is_nil(node.left) do
      remove_node(node, comparator)
    else
      %{node | left: remove_min(node.left, comparator)}
    end
  end

  def max(node) do
    if is_nil(node.right) do
      node.data
    else
      max(node.right)
    end
  end

  def remove_max(node, comparator \\ @default_comparator) do
    if is_nil(node.right) do
      remove_node(node, comparator)
    else
      %{node | right: remove_max(node.right, comparator)}
    end
  end

  # ----------------------------------------------
  # Utils

  defp compare(orig, new, comparator, callback) do
    result =
      case comparator.(new, orig) do
        x when x > 0 -> :is_gt
        x when x < 0 -> :is_lt
        x when x == 0 -> :is_eq
      end

    callback.(result)
  end
end
