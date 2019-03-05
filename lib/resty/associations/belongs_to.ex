defmodule Resty.Associations.BelongsTo do
  alias Resty.Associations.NotLoaded
  defstruct [:related, :attribute, :foreign_key]

  @moduledoc false

  @doc false
  def fetch(association, resource) do
    case Map.get(resource, association.foreign_key) do
      nil -> nil
      id -> Resty.Repo.find(association.related, id)
    end
  end
end
