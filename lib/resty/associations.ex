defmodule Resty.Associations do
  alias Resty.Associations.BelongsTo

  def load(resource = %{__struct__: resource_module}) do
    load(resource, resource_module.associations())
  end

  def load(resource, []), do: resource

  def load(resource, [association | next_associations]) do
    resource = load(resource, association)

    load(resource, next_associations)
  end

  def load(resource, association = %{__struct__: association_module}) do
    association_module.load(association, resource)
  end

  @doc """
  List all of the associations matching the given type defined on the given
  resource.
  """
  def list(%{__struct__: resource_module}, type) do
    list(resource_module, type)
  end

  def list(resource_module, type) when is_atom(resource_module) do
    resource_module.associations
    |> Enum.filter(fn association ->
      association.__struct__ == type
    end)
  end

  @doc """
  Update belongs_to foreign_key on the given resource.
  """
  def update_foreign_keys(resource) do
    resource
    |> list(BelongsTo)
    |> Enum.reduce(resource, fn association, resource ->
      BelongsTo.update_foreign_key(resource, association)
    end)
  end
end
