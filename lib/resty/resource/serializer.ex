defmodule Resty.Resource.Serializer do
  alias Resty.Resource
  alias Resty.Connection

  @doc """
  Given a resource module and a serialized_resource attempt
  to unserialize it.
  """
  @spec deserialize(Resource.resource_module(), Connection.serialized_response()) ::
          [Resource.t()] | Resource.t()
  def deserialize(module, serialized_response) do
    data = module.serializer().decode(serialized_response, module.known_attributes())

    build(module, data)
  end

  @doc "Serialize a resource"
  def serialize(resource), do: serialize(resource.__module__, resource)

  def serialize(module, resource) do
    module.serializer.encode(
      resource,
      module.known_attributes(),
      module.include_root()
    )
  end

  defp build(module, data) when is_list(data) do
    Enum.map(data, &build(module, &1))
  end

  defp build(module, data) do
    data
    |> Enum.concat(__persisted__: true)
    |> module.build()
  end
end
