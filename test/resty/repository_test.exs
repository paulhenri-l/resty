defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Repository

  test "You can find a resource" do
    assert {:ok, %Post{id: 1}} = Repository.find(Post, 1)
  end

  test "You can create a resource" do
    post = Post.build(name: "test")
    {:ok, saved_post} = Repository.save(post)
    {:ok, fetched_post} = Repository.find(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "You can update a resource" do
    {:ok, post} = Post.build(name: "test") |> Repository.save()
    %{post | name: "updated"} |> Repository.save()
    {:ok, updated_post} = Repository.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "You can delete a resource" do
    {:ok, post} = Post.build(name: "Hello from test") |> Repository.save()

    Repository.delete(post)

    assert {:error, %Resty.Error.ResourceNotFound{}} = Repository.find(Post, post.id)
  end
end
