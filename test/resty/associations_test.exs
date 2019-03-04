defmodule Resty.AssociationsTest do
  use ExUnit.Case, async: true
  alias Resty.Associations
  alias Resty.Associations.BelongsTo
  alias Resty.Associations.NotLoaded

  test "By default the association is set to a not loaded association" do
    assert %NotLoaded{} = Post.build().author
  end

  test "List the associations of the given type on the given resource" do
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
end
