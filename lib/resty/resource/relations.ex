defmodule Resty.Resource.Relations do
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
end
