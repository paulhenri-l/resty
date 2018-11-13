defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true
  doctest Resty.Resource
  alias Fakes.Post
  alias Fakes.JsonExtensionResource
  alias Resty.Resource

  @post_headers [
    "Content-Type": "application/json",
    Accept: "application/json; Charset=utf-8",
    Custom: "hello"
  ]

  test "The resource knows its module" do
    assert Post == Post.build().__module__
  end

  test "The resource can be built" do
    assert %Post{id: nil, name: nil} == Post.build()
    assert %Post{id: 1, name: "test"} == Post.build(id: 1, name: "test")
    assert %Post{id: 1, name: "test"} == Post.build(%{id: 1, name: "test"})
  end

  test "The resource holds the headers" do
    assert @post_headers == Post.headers()
  end

  test "The resource can be cloned" do
    original = Post.build(id: 1, name: "Hey!")
    cloned = original |> Resource.clone()

    assert cloned.id == nil
    assert cloned.name == original.name
  end

  test "The resource holds data about its persisted state" do
    refute Post.build() |> Resource.persisted?()
    assert Post.build() |> Resource.new?()

    assert Post.build(__persisted__: true) |> Resource.persisted?()
    refute Post.build(__persisted__: true) |> Resource.new?()
  end

  test "The resource knows which connection to use" do
    assert Fakes.TestConnection = Post.connection()
  end

  test "generate path to resource collection" do
    assert "site.tld/posts" == Post |> Resource.path_to()
    assert "site.tld/with-extension.json" == JsonExtensionResource |> Resource.path_to()
  end

  test "generate path to specific resource" do
    assert "site.tld/posts/1" == Post.build(id: 1) |> Resource.path_to()
    assert "site.tld/posts/1" == Post |> Resource.path_to(1)
    assert "site.tld/posts/uuid" == Post.build(id: "uuid") |> Resource.path_to()
    assert "site.tld/posts/uuid" == Post |> Resource.path_to("uuid")

    assert "site.tld/with-extension/1.json" == JsonExtensionResource.build(id: 1) |> Resource.path_to()
    assert "site.tld/with-extension/1.json" == JsonExtensionResource |> Resource.path_to(1)
    assert "site.tld/with-extension/uuid.json" == JsonExtensionResource.build(id: "uuid") |> Resource.path_to()
    assert "site.tld/with-extension/uuid.json" == JsonExtensionResource |> Resource.path_to("uuid")
  end
end
