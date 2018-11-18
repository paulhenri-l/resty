defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true
  doctest Resty.Resource
  alias Fakes.Post
  alias Fakes.UuidResource
  alias Fakes.JsonExtensionResource
  alias Resty.Resource

  @post_headers [
    "Content-Type": "application/json",
    Accept: "application/json; Charset=utf-8",
    Custom: "hello"
  ]

  test "The resource can be built" do
    assert %Post{id: nil, name: nil} == Post.build()
    assert %Post{id: 1, name: "test"} == Post.build(id: 1, name: "test")
    assert %Post{id: 1, name: "test"} == Post.build(%{id: 1, name: "test"})
  end

  test "The resource holds the headers" do
    assert @post_headers == Post.headers()
  end

  test "The resource can be cloned" do
    original = Post.build(id: 1, name: "Hey!", __persisted__: true)
    cloned = original |> Resource.clone()

    assert cloned.id == nil
    assert cloned |> Resource.new?()
    assert cloned.name == original.name
  end

  test "Primary key is cleared when clonning" do
    original = UuidResource.build(uuid: "hello")
    cloned = original |> Resource.clone()

    assert cloned.uuid == nil
  end

  test "The resource holds data about its persisted state" do
    refute Post.build() |> Resource.persisted?()
    assert Post.build() |> Resource.new?()

    assert Post.build(__persisted__: true) |> Resource.persisted?()
    refute Post.build(__persisted__: true) |> Resource.new?()
  end

  test "The resource knows which connection to use and its params" do
    assert {Fakes.TestConnection, []} = Post.connection()
  end

  test "The resource knows which auth to use and its params" do
    assert {Resty.Auth.Null, []} = Post.auth()
  end

  test "The resource knows which serializer to use and its params" do
    assert {Resty.Serializer.Json, []} = Post.serializer()
  end

  test "generate path to resource collection" do
    assert "site.tld/posts" == Post |> Resource.url_for()
    assert "site.tld/with-extension.json" == JsonExtensionResource |> Resource.url_for()
  end

  test "generate path to specific resource" do
    # url_for/1
    assert "site.tld/posts" == Post |> Resource.url_for()
    assert "site.tld/posts/1" == %Post{id: 1} |> Resource.url_for()
    assert "site.tld/posts/uuid" == %UuidResource{uuid: "uuid"} |> Resource.url_for()

    # url_for/2
    assert "site.tld/posts/1" == Post |> Resource.url_for(1)
    assert "site.tld/posts?key=value" == Post |> Resource.url_for(key: "value")
    assert "site.tld/posts/1?key=value" == %Post{id: 1} |> Resource.url_for(key: "value")

    assert "site.tld/posts/uuid?key=value" ==
             %UuidResource{uuid: "uuid"} |> Resource.url_for(key: "value")

    # url_for/3
    assert "site.tld/posts/1?key=value" == Post |> Resource.url_for(1, key: "value")
  end
end
