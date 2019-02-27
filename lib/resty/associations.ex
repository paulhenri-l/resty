defmodule Resty.Associations do
  alias Resty.Associations.BelongsTo

  @moduledoc """
  Resty supports associations between resources. The best way to learn how to
  use an association is to go check its doc.

  ## Supported associations
  - `Resty.Resource.Base.belongs_to/3`

  ## Not loaded

  If an association has not been loaded its value will be of the type
  `Resty.Associations.NotLoaded`

  What may cause an association to not be loaded is that the request resulted
  in an error (404, 401 etc...) or that the foreign key of the relation was
  set to null.
  """

  @doc false
  def load(resource = %{__struct__: resource_module}) do
    load(resource, resource_module.associations())
  end

  @doc false
  def load(resource, []), do: resource

  def load(resource, [association | next_associations]) do
    resource = load(resource, association)

    load(resource, next_associations)
  end

  def load(resource, association = %{__struct__: association_module}) do
    association_module.load(association, resource)
  end

  @doc false
  def list(%{__struct__: resource_module}, type) do
    list(resource_module, type)
  end

  def list(resource_module, type) when is_atom(resource_module) do
    resource_module.associations
    |> Enum.filter(fn association ->
      association.__struct__ == type
    end)
  end
end
