# Filter meta fileds when serializing
# Filter all unwanted fields when creating

defmodule Resty.Resource.Serializer do
  @doc """
  Given a resource module and a serialized_resource attempt
  to unserialize it.
  """
  def deserialize(module, serialized_resource) do
    serialized_resource
    |> decode()
    |> handle_decode_error()
    |> filter_fields(module.fields)
    # |> cast_fields()
    # |> load_relations()
    |> build(module)
  end

  @doc "Serialize a resource"
  def serialize(resource) do
    resource
    |> encode()
    |> handle_encode_error()
  end

  defp encode(resource) do
    resource |> Jason.encode()
  end

  defp decode(response) do
    response |> Jason.decode()
  end

  defp handle_decode_error({:ok, data}), do: data

  defp handle_decode_error({:error, error}) do
    # Should create custom DecodingError
    raise error
  end

  defp handle_encode_error({:ok, data}), do: data

  defp handle_encode_error({:error, error}) do
    # Should create custom EncodingError
    raise error
  end

  defp filter_fields(data, expected_fields) do
    do_filter_fields(expected_fields, data, %{})
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

  defp build(data, module), do: struct(module, data)
end
