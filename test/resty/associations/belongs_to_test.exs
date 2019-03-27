defmodule Resty.Associations.BelongsToTest do
  use ExUnit.Case, async: true

  alias Resty.Associations.LoadError

  test "BelongsTo relationships are automatically loaded" do
    post = Resty.Repo.find!(Post, 1)

    assert post.author.__struct__ == Author
    assert post.author.id == 1
    assert post.author.name == "PH"
  end

  test "If the resource is not persisted loading the association won't result in an error" do
    post = Post.build() |> Resty.Associations.load()
    assert %Resty.Associations.NotLoaded{} = post.author

    post = Post.build(author_id: 1) |> Resty.Associations.load()
    assert %Author{name: "PH"} = post.author
  end

  test "BelongsTo relationships are not loaded if they result in an error" do
    post = Resty.Repo.find!(Post, 4)

    assert post.author == %LoadError{
             error: %Resty.Error.ResourceNotFound{code: 404, message: ""}
           }
  end
end
