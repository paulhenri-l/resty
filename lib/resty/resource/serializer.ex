defmodule Resty.Resource.Serializer do
  @doc """
  Given a resource module and a serialized_resource attempt
  to unserialize it.
  """
  def deserialize(module, serialized_resource) do
    data = module.serializer().decode(serialized_resource, module.fields())
    # |> load_relations()

    module.build(data)
  end

  @doc "Serialize a resource"
  def serialize(resource) do
    resource |> Jason.encode!()
  end
end
