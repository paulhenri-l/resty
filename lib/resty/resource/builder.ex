defmodule Resty.Resource.Builder do
  alias Resty.Resource.Attributes
  @moduledoc false

  def build(module, attributes, persisted \\ nil) do
    module
    |> struct(attributes)
    |> set_persisted_state(persisted)
  end

  defp set_persisted_state(resource, nil), do: resource

  defp set_persisted_state(resource, persisted) do
    Map.put(resource, :__persisted__, persisted)
  end
end
