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
    parse_data(tree, [])
  end

  defp parse_data(nil, acc), do: acc

  defp parse_data(%Bst{data: data, right: nil, left: nil}, acc), do: [data | acc]

  defp parse_data(tree, acc) do
    parse_data(tree.right, acc) |> (fn acc -> parse_data(tree.left, [tree.data | acc]) end).()
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
