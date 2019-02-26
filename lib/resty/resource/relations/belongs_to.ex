defmodule Resty.Resource.Relations.BelongsTo do
  @moduledoc false

  alias Resty.Resource.Relations.NotLoaded

  defstruct [:related, :attribute, :foreign_key]

  def load(relation, resource) do
    related =
      case Map.get(resource, relation.foreign_key) do
        nil -> nil
        id -> Resty.Repo.find(relation.related, id)
      end

    case related do
      {:ok, related_resource} ->
        Map.put(resource, relation.attribute, related_resource)

      nil ->
        Map.put(resource, relation.attribute, %NotLoaded{})

      {:error, _} ->
        Map.put(resource, relation.attribute, %NotLoaded{})
    end
  end

  def update_foreign_key(resource, relation) do
    case Map.get(resource, relation.attribute) do
      %NotLoaded{} ->
        resource

      related ->
        id = Resty.Resource.get_primary_key(related)
        Map.put(resource, relation.foreign_key, id)
    end
  end
end
