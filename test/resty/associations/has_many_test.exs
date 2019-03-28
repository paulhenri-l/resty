defmodule Resty.Associations.HasManyTest do
  use ExUnit.Case, async: true

  alias Resty.Associations.LoadError

  test "HasMany associations are automatically fetched and loaded" do
    post = Resty.Repo.find!(Post, 1)

    assert [%Post.Comment{id: 1, body: "My first comment"} | _] = post.comments
  end

  test "If the resource is not persisted the associations won't be fetched" do
    post = Post.build() |> Resty.Associations.load()

    assert %Resty.Associations.NotLoaded{} = post.comments
  end

  test "If the associationn is already in the resource it wont get refetched" do
    post = Resty.Repo.find!(Post, 2)

    assert [%Post.Comment{id: 4, body: "A comment"} | _] = post.comments
  end

  test "HasMany associations are not loaded if they result in an error" do
    post = Resty.Repo.find!(Post, 3)

    assert post.comments == %LoadError{
             error: %Resty.Error.ResourceNotFound{code: 404, message: ""}
           }
  end
end
