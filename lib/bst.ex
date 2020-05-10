defmodule Bst do
  @enforce_keys [:data]
  defstruct [:data, :left, :right]

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

  def insert(tree, new_data) do
    insert_node(tree, %Bst{data: new_data})
  end

  defp insert_node(nil, new_node), do: new_node

  # TODO: Decide where equal values go to.
  defp insert_node(tree, new_node) do
    compare(tree.data, new_node.data, fn
      :is_gt -> %{tree | right: insert_node(tree.right, new_node)}
      :is_lt -> %{tree | left: insert_node(tree.left, new_node)}
      :is_eq -> %{tree | left: insert_node(tree.left, new_node)}
    end)
  end

  # ----------------------------------------------
  # delete/2

  def delete(nil, _data), do: nil

  def delete(tree, data) do
    compare(tree.data, data, fn
      :is_gt -> %{tree | right: delete(tree.right, data)}
      :is_lt -> %{tree | left: delete(tree.left, data)}
      :is_eq -> remove_node(tree)
    end)
  end

  defp remove_node(%Bst{data: nil}), do: nil
  defp remove_node(%Bst{right: nil, left: left}), do: left
  defp remove_node(%Bst{right: right, left: nil}), do: right

  # TODO: Choose side more garcefully.
  defp remove_node(%Bst{right: right, left: left}) do
    insert_node(right, left)
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

  def remove_min(node) do
    if is_nil(node.left) do
      remove_node(node)
    else
      %{node | left: remove_min(node.left)}
    end
  end

  def max(node) do
    if is_nil(node.right) do
      node.data
    else
      max(node.right)
    end
  end

  def remove_max(node) do
    if is_nil(node.right) do
      remove_node(node)
    else
      %{node | right: remove_max(node.right)}
    end
  end

  # ----------------------------------------------
  # Utils

  defp compare(orig, new, callback) do
    result =
      case new - orig do
        x when x > 0 -> :is_gt
        x when x < 0 -> :is_lt
        x when x == 0 -> :is_eq
      end

    callback.(result)
  end
end
