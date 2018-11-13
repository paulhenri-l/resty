defmodule Resty.Serializer do
  alias Resty.Resource

  @moduledoc """
  This module is used by `Resty.Repo` in order to serialize and deserialize
  data sent and received from the web API.

  It will use the `Resty.Serializer` implementation configured on the resource.
  By default it is `Resty.Serializer.Json` but if you want to use another
  format you'll have to write your own implementation of this behaviour.

  Once that's done you'll be able to use it on a per resource basis by calling
  the appropriate `Resty.Resource.Base` macro or globally by setting it in the
  config.
  """

  @type t() :: module()
  @type serialized() :: binary()
  @type decoded() :: [Enum.t()] | Enum.t()
  @type known_attributes() :: [atom()]

  @doc """
  Decode the given serialized data and only allow the given known_attributes
  in the decoded data.
  """
  @callback decode(serialized :: binary(), known_attributes :: known_attributes()) :: decoded()

  @doc """
  Encode the known_attributes from the given map into its serialized form and
  put them inside a root node of the given root_name if one is given.
  """
  @callback encode(map :: map(), known_attributes :: known_attributes, root_name :: false | String.t()) :: serialized()

  @doc """
  Given a resource module and a serialized resource attempt
  to unserialize it.
  """
  @spec deserialize(Resource.resource_module(), serialized()) ::
          Resource.collection() | Resource.t()
  def deserialize(module, serialized) do
    data = module.serializer().decode(serialized, module.known_attributes())

    build(module, data)
  end

  @doc """
  Given a resource struct return its serialized counterpart.
  """
  @spec serialize(Resource.t()) :: binary()
  def serialize(resource), do: serialize(resource.__module__, resource)

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
