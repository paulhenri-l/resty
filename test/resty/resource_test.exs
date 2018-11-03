defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true
  alias Fakes.Post

  @json_read_resource ~s|{"data":{"id":1, "name": "test"}}|
  @json_write_resource ~s|{"pipeline":{"id":1, "name": "test"}}|

  # Add test for resource without json nesting key
  # Add test for resource with read, write json key

  test "The resource can generate paths" do
    pipeline = Post.build(id: 1)

    assert "localhost:3000/pipelines" == Post.path()
    assert "localhost:3000/pipelines/1" == Post.path(1)
    assert "localhost:3000/pipelines/1" == Post.path(pipeline)
  end

  test "The resource knows its module" do
    assert Post == Post.build().__module__
  end

  test "The resource can be built" do
    assert %Post{id: nil, name: nil} == Post.build()
    assert %Post{id: 1, name: "test"} == Post.build(id: 1, name: "test")
    assert %Post{id: 1, name: "test"} == Post.build(%{id: 1, name: "test"})
  end

  test "The resource can be created from json" do
    assert %Post{id: 1, name: "test"} == Post.from_json(@json_read_resource)
  end

  test "The resource can be converted to json" do
    pipeline = Post.build(id: 1, name: "test")

    assert Poison.decode!(@json_write_resource) == Poison.decode!(Post.to_json(pipeline))
  end
end
