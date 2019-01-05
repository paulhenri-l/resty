defmodule Resty.Resource.Relations.BelongsTo do
  @moduledoc false

  defstruct [:related, :attribute, :foreign_key]

  def load(relation, resource) do
    IO.inspect("load")
    resource
  end
end
