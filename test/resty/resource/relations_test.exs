defmodule Resty.Resource.RelationsTest do
  use ExUnit.Case, async: true
  alias Resty.Resource.Relations
  alias Resty.Resource.Relations.BelongsTo
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

  test "You can update a belongs_to relation" do
    post = Resty.Repo.find!(Post, 4)
    author = Resty.Repo.find!(Author, 1)

    # Test update attribute as well.
    updated_post = %{post | author: author} |> Resty.Repo.save!()

    assert updated_post.author.__struct__ == Author
    assert updated_post.author.id == 1
    assert updated_post.author.name == "PH"
  end

  test "Return the resource configured belongs_to relations" do
    author_relations = Author.build() |> Relations.list(BelongsTo)
    post_relations = Post |> Relations.list(BelongsTo)

    assert author_relations == []

    assert post_relations == [
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

    post = Relations.update_foreign_keys(post)

    assert post.author_id == 1
  end
end
