defmodule Resty.Resource.Builder do
  @moduledoc false

  def build(module, attributes, filter_unknown \\ true) do
    attributes = attributes |> Enum.into(%{})

    attributes = case filter_unknown do
      true -> remove_unknown(attributes, module.known_attributes())
      false -> attributes
    end

    struct(module, attributes)
  end

  def remove_unknown(data, known_attributes) do
    do_remove_unknown(known_attributes, data, %{})
  end

  defp do_remove_unknown([], _, filtered_attributes), do: filtered_attributes

  defp do_remove_unknown([attribute | next_attributes], data, filtered_attributes) do
    attribute_string_key = attribute |> to_string()

    value =
      case Map.get(data, attribute, :no_val) do
        :no_val -> Map.get(data, attribute_string_key, :no_val)
        value -> value
      end

    updated_filtered_attributes =
      case value do
        :no_val -> filtered_attributes
        value -> Map.put(filtered_attributes, attribute, value)
      end

    do_remove_unknown(next_attributes, data, updated_filtered_attributes)
  end
end
