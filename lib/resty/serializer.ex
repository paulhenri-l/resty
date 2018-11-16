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

  @doc """
  Given a resource module and a serialized resource attempt
  to unserialize it.
  """
  def deserialize(module, serialized) do
    data = module.serializer().decode(serialized, module.known_attributes())

    build(module, data)
  end

  @doc """
  Given a resource struct return its serialized counterpart.
  """
  def serialize(resource), do: serialize(resource.__struct__, resource)

  defp serialize(module, resource) do
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
