defmodule Resty.Serializer.Json do
  @moduledoc """
  Serialize and deserialize resources structs from and to json. This is the
  default `Resty.Serializer` implementation.
  """

  def decode(json, known_attributes) do
    json
    |> do_decode()
    |> remove_root()
    |> remove_unknown_attributes(known_attributes)
  end

  defp do_decode(json) do
    case Jason.decode(json) do
      {:error, error} -> raise error
      {:ok, result} -> result
    end
  end

  defp remove_root(list) when is_list(list), do: list

  defp remove_root(map), do: do_remove_root(map, Map.keys(map))

  defp do_remove_root(map, [key | []]) do
    case Map.get(map, key) do
      data when is_map(data) -> data
      data when is_list(data) -> data
      _ -> map
    end
  end

  defp do_remove_root(map, _), do: map

  defp remove_unknown_attributes(data, known_attributes) when is_list(data) do
    Enum.map(data, &do_remove_unknown_attributes(known_attributes, &1, %{}))
  end

  defp remove_unknown_attributes(data, known_attributes) do
    do_remove_unknown_attributes(known_attributes, data, %{})
  end

  defp do_remove_unknown_attributes([], _, filtered_attributes), do: filtered_attributes

  defp do_remove_unknown_attributes([attribute | next_attributes], data, filtered_attributes) do
    attribute_key = attribute |> to_string()

    updated_filtered_attributes =
      case Map.get(data, attribute_key, false) do
        false ->
          filtered_attributes

        value ->
          Map.put(filtered_attributes, attribute, value)
      end

    do_remove_unknown_attributes(next_attributes, data, updated_filtered_attributes)
  end

  # Encoding
  def encode(map, known_attributes, root \\ false) do
    map = Map.take(map, known_attributes)

    to_encode =
      case root do
        false -> map
        root -> Map.put(%{}, root, map)
      end

    to_encode |> Jason.encode!([])
  end
end
