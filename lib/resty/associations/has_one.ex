defmodule Resty.Associations.HasOne do
  alias Resty.Associations.NotLoaded
  defstruct [:related, :attribute, :foreign_key]

  @moduledoc false

  @doc false
  def load(association, resource) do
    # Do not refetech if relation already in the resource. Simply put it in the
    # correct struct.
    #
    # Allow to disable automatic fetching of relationns in order to avoid circular.
    #
    # Remove duplicates between both has_one an belongs_to
    foreign_key_value = resource |> Resty.Resource.get_primary_key()

    related =
      Resty.Repo.find(
        association.related,
        nil,
        [{association.foreign_key, foreign_key_value}]
      )

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
