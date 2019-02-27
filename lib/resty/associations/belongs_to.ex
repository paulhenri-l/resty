defmodule Resty.Associations.BelongsTo do
  alias Resty.Associations.NotLoaded
  defstruct [:related, :attribute, :foreign_key]

  @moduledoc false

  @doc false
  def load(association, resource) do
    related =
      case Map.get(resource, association.foreign_key) do
        nil -> nil
        id -> Resty.Repo.find(association.related, id)
      end

    case related do
      {:ok, related_resource} ->
        Map.put(resource, association.attribute, related_resource)

      nil ->
        Map.put(resource, association.attribute, %NotLoaded{})

      {:error, _} ->
        Map.put(resource, association.attribute, %NotLoaded{})
    end
  end
end
