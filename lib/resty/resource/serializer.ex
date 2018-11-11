defmodule Resty.Resource.Serializer do
  @doc """
  Given a resource module and a serialized_resource attempt
  to unserialize it.
  """
  def deserialize(module, serialized_resource) do
    data = module.serializer().decode(serialized_resource, module.fields())

    build(module, data)
  end

  @doc "Serialize a resource"
  def serialize(resource), do: serialize(resource.__module__, resource)

  def serialize(module, resource) do
    module.serializer.encode(
      resource,
      module.fields(),
      module.include_root()
    )
  end

  defp build(module, data) when is_list(data) do
    Enum.map(data, &build(module, &1))
  end

  defp build(module, data) do
    module.build(data)
  end
end
