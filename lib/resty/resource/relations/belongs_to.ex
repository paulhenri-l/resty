defmodule Resty.Resource.Relations.BelongsTo do
  @moduledoc false

  defstruct [:related, :attribute, :foreign_key]

  def load(relation, resource) do
    IO.inspect("load")
    IO.inspect(relation)
    IO.inspect(resource)

    id = Map.get(resource, relation.foreign_key)
    related = Resty.Repo.find(relation.related, id)

    case related do
      {:ok, related_resource} ->
        Map.put(resource, relation.attribute, related_resource)

      {:error, _} ->
        Map.put(resource, relation.attribute, %Resty.Resource.Relations.NotLoaded{})
    end
  end
end
