defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Repository

  test "You can find a resource" do
    assert %Post{id: 1} = Repository.find(Post, 1)
  end

  test "You can create a resource" do
    pipeline = Post.build(name: "test")
    saved_pipeline = Repository.save(pipeline)

    assert pipeline.name == saved_pipeline.name
    assert pipeline.name == Repository.find(Post, saved_pipeline.id).name
  end
end
