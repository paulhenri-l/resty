defmodule Resty.Resource.Attributes do
  @moduledoc false

  def remove_unknown_attributes(data, known_attributes) when is_list(data) do
    Enum.map(data, &do_remove_unknown_attributes(known_attributes, &1, %{}))
  end

  def remove_unknown_attributes(data, known_attributes) do
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
end
