defmodule Resty.AssociationsTest do
  use ExUnit.Case, async: true
  alias Resty.Associations
  alias Resty.Associations.BelongsTo
  alias Resty.Associations.NotLoaded

  test "By default the association is set to a not loaded association" do
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

  test "You can update a belongs_to association" do
    post = Resty.Repo.find!(Post, 4)
    author = Resty.Repo.find!(Author, 1)

    # Test update attribute as well.
    updated_post = %{post | author: author} |> Resty.Repo.save!()

    assert updated_post.author.__struct__ == Author
    assert updated_post.author.id == 1
    assert updated_post.author.name == "PH"
  end

  test "Return the resource configured belongs_to associations" do
    author_associations = Author.build() |> Associations.list(BelongsTo)
    post_associations = Post |> Associations.list(BelongsTo)

    assert author_associations == []

    assert post_associations == [
             %BelongsTo{
               attribute: :author,
               foreign_key: :author_id,
               related: Author
             }
           ]
  end

  test "Update the resource belongs_to foreign keys" do
    post = Resty.Repo.find!(Post, 4)
    author = Resty.Repo.find!(Author, 1)

    post = %{post | author: author}

    # Still the old author_id
    assert post.author_id == 2

    post = Associations.update_foreign_keys(post)

    assert post.author_id == 1
  end
end
