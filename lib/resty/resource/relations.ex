defmodule Resty.Resource.Relations do
  alias Resty.Resource.Relations.BelongsTo

  def load(resource) do
    load(resource, resource.__struct__.relations())
  end

  def load(resource, []), do: resource

  def load(resource, [relation | next_relations]) do
    resource = load(resource, relation)

    load(resource, next_relations)
  end

  def load(resource, relation = %{__struct__: relation_module}) do
    relation_module.load(relation, resource)
  end

  @doc """
  List all of the relations matching the given type defined on the given
  resource.
  """
  def list(%{__struct__: resource_module}, type) do
    list(resource_module, type)
  end

  def list(resource_module, type) when is_atom(resource_module) do
    resource_module.relations |> Enum.filter(fn relation ->
      relation.__struct__ == type
    end)
  end

  @doc """
  Update belongs_to foreign_key on the given resource.
  """
  def update_foreign_keys(resource) do
    resource
    |> list(BelongsTo)
    |> Enum.reduce(resource, fn (relation, resource) ->
      BelongsTo.update_foreign_key(resource, relation)
    end)
  end
end
