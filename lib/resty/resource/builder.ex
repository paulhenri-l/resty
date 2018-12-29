defmodule Resty.Resource.Builder do
  alias Resty.Resource.Attributes
  @moduledoc false

  def build(module, attributes, persisted) do
    module
    |> struct(attributes)
    |> init_relations(module.relations())
    |> set_persisted_state(persisted)
  end

  defp init_relations(resource, []), do: resource

  defp init_relations(resource, [{attribute, module} | next_relations]) do
    case Map.get(resource, attribute, nil) do
      nil ->
        init_relations(resource, next_relations)

      data ->
        builded_relation =
          Attributes.remove_unknown_attributes(data, module.known_attributes())
          |> module.build(true)

        resource = Map.put(resource, attribute, builded_relation)

        init_relations(resource, next_relations)
    end
  end

  defp set_persisted_state(resource, persisted) do
    Map.put(resource, :__persisted__, persisted)
  end
end
