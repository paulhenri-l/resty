defmodule Resty.Resource.SerialierTest do
  use ExUnit.Case, async: true

  alias Resty.Serializer

  @json_resource ~s({"id":1, "name": "test", "fake-attribute": "value"})
  @corrupted_json_resource """
  {"__struct__": "Hola", "fake-attribute": "value"}
  """

  test "Serializing a resource" do
    # I am not sure if the relations should be serialized.
    assert ~s({"body":"lorem","id":1,"name":"test"}) == Post.build(id: 1, name: "test", body: "lorem") |> Serializer.serialize()
  end

  test "Deserializing a resource" do
    assert %Post{id: 1, name: "test"} = Serializer.deserialize(@json_resource, Post)
    assert Post == Serializer.deserialize(@json_resource, Post).__struct__
  end

  test "Unknown attributes are cleaned when deserializing" do
    post = Serializer.deserialize(@corrupted_json_resource, Post)

    assert nil == Map.get(post, :"fake-attribute")
    assert Post == Map.get(post, :__struct__)
  end

  test "The Serializer marks resources as persisted when deserializing" do
    assert %Post{__persisted__: true} = Serializer.deserialize(@json_resource, Post)
  end
end
