defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true

  @json_read_resource ~s|{"data":{"id":1, "name": "test"}}|
  @json_write_resource ~s|{"pipeline":{"id":1, "name": "test"}}|

  # Add test for resource without json nesting key
  # Add test for resource with read, write json key

  test "The resource can generate paths" do
    pipeline = Pipeline.build(id: 1)

    assert "localhost:3000/pipelines" == Pipeline.path()
    assert "localhost:3000/pipelines/1" == Pipeline.path(1)
    assert "localhost:3000/pipelines/1" == Pipeline.path(pipeline)
  end

  test "The resource knows its module" do
    assert Pipeline == Pipeline.build().__module__
  end

  test "The resource can be built" do
    assert %Pipeline{id: nil, name: nil} == Pipeline.build()
    assert %Pipeline{id: 1, name: "test"} == Pipeline.build(id: 1, name: "test")
    assert %Pipeline{id: 1, name: "test"} == Pipeline.build(%{id: 1, name: "test"})
  end

  test "The resource can be created from json" do
    assert %Pipeline{id: 1, name: "test"} == Pipeline.from_json(@json_read_resource)
  end

  test "The resource can be converted to json" do
    pipeline = Pipeline.build(id: 1, name: "test")

    assert Poison.decode!(@json_write_resource) == Poison.decode!(Pipeline.to_json(pipeline))
  end
end
