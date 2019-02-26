defmodule Resty.Resource.Relations.BelongsTo do
  @moduledoc false

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
        Map.put(resource, relation.attribute, %Resty.Resource.Relations.NotLoaded{})

      {:error, _} ->
        Map.put(resource, relation.attribute, %Resty.Resource.Relations.NotLoaded{})
    end
  end
end
