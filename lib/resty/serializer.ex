defmodule Resty.Serializer do
  @moduledoc """
  This module is used by `Resty.Repo` in order to serialize and deserialize
  data sent and received from the web API.

  It will use the serializer implementation configured on the resource. By
  default it is `Resty.Serializer.Json` but if you want to use another format
  you'll have to write your own implementation.

  Once that's done you'll be able to use it on a per resource basis by calling
  the appropriate `Resty.Resource.Base` macro or globally by setting it in the
  config.
  """

  @doc false
  def deserialize(serialized, resource_module) do
    {implementation, params} = resource_module.serializer()

    data = implementation.decode(serialized, resource_module.known_attributes(), params)

    build(resource_module, data)
  end

  @doc false
  def serialize(resource), do: serialize(resource, resource.__struct__)

  defp serialize(resource, resource_module) do
    {implementation, params} = resource_module.serializer()

    implementation.encode(
      resource,
      resource_module.known_attributes(),
      params ++ [include_root: resource_module.include_root()]
    )
  end

  defp build(resource_module, data) when is_list(data) do
    Enum.map(data, &build(resource_module, &1))
  end

  defp build(resource_module, data) do
    data
    |> Enum.concat(__persisted__: true)
    |> resource_module.build()
  end
end
