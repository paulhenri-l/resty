defmodule Resty.Resource.Serializer do
  @doc """
  Given a resource module and a serialized_resource attempt
  to unserialize it.
  """
  def deserialize(module, serialized_resource) do
    module.serializer().decode(serialized_resource, module)
  end

  @doc "Serialize a resource"
  def serialize(resource) do
    resource
    |> Jason.encode!()
  end
end
