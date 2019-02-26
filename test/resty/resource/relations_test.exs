defmodule Resty.Resource.RelationsTest do
  use ExUnit.Case, async: true
  # alias Resty.Resource.Relations
  alias Resty.Resource.Relations.NotLoaded

  test "By default the relation is set to a not loaded relation" do
    assert %NotLoaded{} = Post.build().author
  end

  test "BelongsTo relationships are automatically loaded" do
    post = Resty.Repo.find!(Post, 1)

    assert post.author.__struct__ == Author
    assert post.author.id == 1
    assert post.author.name == "PH"
  end

  test "BelongsTo relationships are not loaded if they result in an error" do
    post = Resty.Repo.find!(Post, 4)

    assert post.author == %NotLoaded{}
  end
end
