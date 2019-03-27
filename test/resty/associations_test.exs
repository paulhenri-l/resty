defmodule Resty.AssociationsTest do
  use ExUnit.Case, async: true
  alias Resty.Associations
  alias Resty.Associations.BelongsTo
  alias Resty.Associations.HasOne
  alias Resty.Associations.NotLoaded

  test "By default the association is set to a not loaded association" do
    assert %NotLoaded{} = Post.build().author
  end

  test "Associations can be eager loaded, or not" do
    author = Author |> Resty.Repo.find!(1)
    address = author.address

    assert address.city == "Somewhere"
    assert address.author == %NotLoaded{}

    address = Resty.Associations.load(address)

    assert address.author.id == 1
  end

  test "List the associations of the given type on the given resource" do
    author_associations = Author.build() |> Associations.list(HasOne)
    post_associations = Post |> Associations.list(BelongsTo)

    assert author_associations == [
             %HasOne{
               attribute: :address,
               foreign_key: :author_id,
               related: Author.Address
             }
           ]

    assert post_associations == [
             %BelongsTo{
               attribute: :author,
               foreign_key: :author_id,
               related: Author
             }
           ]
  end
end
