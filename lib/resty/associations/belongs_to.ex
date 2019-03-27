defmodule Resty.Associations.BelongsTo do
  defstruct [:related, :attribute, :foreign_key, {:eager_load, true}]

  @moduledoc false

  @doc false
  def fetch(association, resource) do
    case Map.get(resource, association.foreign_key) do
      nil -> nil
      id -> Resty.Repo.find(association.related, id)
    end
  end
end
