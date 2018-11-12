defmodule Resty.ResourceTest do
  use ExUnit.Case, async: true
  doctest Resty.Resource
  alias Fakes.Post
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
end
