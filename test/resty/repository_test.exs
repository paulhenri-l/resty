defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Repository

  test "You can find a resource" do
    assert %Post{id: 1} = Repository.find(Post, 1)
  end

  test "You can create a resource" do
    post = Post.build(name: "test")
    saved_post = Repository.save(post)

    assert post.name == saved_post.name
    assert post.name == Repository.find(Post, saved_post.id).name
  end
end
