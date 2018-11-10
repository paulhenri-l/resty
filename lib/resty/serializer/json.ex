defmodule Resty.Serializer.Json do
  # Decoding
  def decode(json, module) do
    json
    |> to_map()
    |> filter_fields(module.fields())
    # |> cast_fields()
    # |> load_relations()
    |> module.build()
  end

  # defp decode_item(), do: nil
  # defp decode_collection(), do: nil

  defp to_map(json) do
    case Jason.decode(json) do
      {:error, error} -> raise error
      {:ok, result} -> result
    end
  end

  defp filter_fields(data, resource_fields) do
    do_filter_fields(resource_fields, data, %{})
  end

  defp do_filter_fields([], _, filtered_fields), do: filtered_fields

  defp do_filter_fields([field | next_fields], data, filtered_fields) do
    field_key = field |> to_string()

    updated_filtered_fields =
      case Map.get(data, field_key, false) do
        false ->
          filtered_fields

        value ->
          Map.put(filtered_fields, field, value)
      end

    do_filter_fields(next_fields, data, updated_filtered_fields)
  end

  # Encoding
  def encode(_struct) do
  end
end
