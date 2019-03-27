defmodule Resty.Associations.HasOne do
  defstruct [:related, :attribute, :foreign_key]

  @moduledoc false

  @doc false
  def load(_, _resource = %{__persisted__: false}) do
    nil
  end

  def fetch(association, resource) do
    # Allow to disable automatic fetching of relationns in order to avoid circular.

    case Map.get(resource, association.attribute, nil) do
      %Resty.Associations.NotLoaded{} ->
        do_fetch(association, resource)

      preloaded_relation ->
        do_preload(preloaded_relation, association)
    end
  end

  defp do_fetch(association, resource) do
        Resty.Repo.find(association.related, nil, [
          {
            association.foreign_key,
            Resty.Resource.get_primary_key(resource)
          }
        ])
  end

  defp do_preload(preloaded_relation, association) do
        relation =
          preloaded_relation
          |> association.related.build()
          |> Resty.Resource.mark_as_persisted()

        {:ok, relation}
  end
end
