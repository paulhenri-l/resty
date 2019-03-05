defmodule Resty.Associations.HasOne do
  defstruct [:related, :attribute, :foreign_key]

  @moduledoc false

  @doc false
  def load(_, resource = %{__persisted__: false}) do
    nil
  end

  def fetch(association, resource) do
    # Do not refetech if relation already in the resource. Simply put it in the
    # correct struct.
    #
    # Allow to disable automatic fetching of relationns in order to avoid circular.
    #
    # Remove duplicates between both has_one an belongs_to
    Resty.Repo.find(association.related, nil, [
      {
        association.foreign_key,
        Resty.Resource.get_primary_key(resource)
      }
    ])
  end
end
