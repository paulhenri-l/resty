defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true

  test "The resource site can be retrieved" do
    assert "localhost:3000" === Pipeline.site()
  end

  test "The resource path can be retrieved" do
    assert "pipelines" === Pipeline.path()
  end

  test "The resource can be built" do
    assert %Pipeline{id: nil, name: nil} == Pipeline.build()
    assert %Pipeline{id: 1, name: "test"} == Pipeline.build(%{id: 1, name: "test"})
    assert %Pipeline{id: 1, name: "test"} == Pipeline.build(~s|{"id":1, "name": "test"}|)
  end
end
