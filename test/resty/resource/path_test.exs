defmodule Resty.Resource.PathTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Resource.Path

  test "generate path to resource collection" do
    assert "site.tld/posts" == Post |> Path.to()
  end

  test "generate path to specific resource" do
    assert "site.tld/posts/1" == Post.build(id: 1) |> Path.to()
    assert "site.tld/posts/uuid" == Post.build(id: "uuid") |> Path.to()

    assert "site.tld/posts/1" == Post |> Path.to(1)
    assert "site.tld/posts/uuid" == Post |> Path.to("uuid")
  end
end
