defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true
  alias Fakes.Post

  @json_resource ~s({"id":1, "name": "test"})
  # Add test for resource with read, write json key

  test "The resource can generate paths" do
    post = Post.build(id: 1)

    assert "site.tld/posts" == Post.path()
    assert "site.tld/posts/1" == Post.path(1)
    assert "site.tld/posts/uuid" == Post.path("uuid")
    assert "site.tld/posts/1" == Post.path(post)
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
    assert %Post{id: 1, name: "test"} == Post.from_json(@json_resource)
    assert Post == Post.from_json(@json_resource).__module__
  end

  test "Fields are cleaned when the resource is created from json" do
    json =
      Poison.encode!(%{
        id: 1,
        name: "hello",
        __module__: "Hola"
      })

    assert %Post{id: 1, name: "hello", __module__: Post} == Post.from_json(json)
  end

  test "The resource can be converted to json" do
    post = Post.build(id: 1, name: "test")

    assert Poison.decode!(@json_resource) == Poison.decode!(Post.to_json(post))
  end
end
