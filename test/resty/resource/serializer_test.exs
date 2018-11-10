defmodule Resty.Resource.SerialierTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Resource.Serializer

  @json_resource ~s({"id":1, "name": "test", "fake-field": "value"})
  @corrupted_json_resource """
  {"__module__": "Hola", "fake-field": "value"}
  """

  test "Serializing a resource" do
    assert ~s({"id":1,"name":"test"}) == Post.build(id: 1, name: "test") |> Serializer.serialize()
  end

  test "Deserializing a resource" do
    assert %Post{id: 1, name: "test"} = Serializer.deserialize(Post, @json_resource)
    assert Post == Serializer.deserialize(Post, @json_resource).__module__
  end

  test "Unknown fields are cleaned when deserializing" do
    post = Serializer.deserialize(Post, @corrupted_json_resource)

    assert nil == Map.get(post, :"fake-field")
    assert Post == Map.get(post, :__module__)
  end
end
