defmodule Resty.Resource.Builder do
  @moduledoc false

  def build(module, attributes, filter_unknown \\ true) do
    attributes = attributes |> Enum.into(%{})

    attributes =
      case filter_unknown do
        true -> remove_unknown(attributes, module.known_attributes())
        false -> attributes
      end

    struct(module, attributes) |> load_relations()
  end

  defp remove_unknown(atrributes_to_filter, known_attributes) do
    remove_unknown(atrributes_to_filter, known_attributes, %{})
  end

  defp remove_unknown(_, [], filtered_attributes), do: filtered_attributes

  defp remove_unknown(data, [{attribute, _default_value} | next_attributes], filtered_attributes) do
    remove_unknown(data, [attribute | next_attributes], filtered_attributes)
  end

  defp remove_unknown(data, [attribute | next_attributes], filtered_attributes) do
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

    remove_unknown(data, next_attributes, updated_filtered_attributes)
  end

  defp load_relations(resource) do
    resource |> Resty.Relations.load()
  end
end
