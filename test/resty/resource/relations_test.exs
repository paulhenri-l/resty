defmodule Resty.Resource.RelationsTest do
  use ExUnit.Case, async: true
  alias Resty.Resource.Relations

  test "BelongsTo relationships can be loaded" do
    post = Post.build(author_id: 1)

    post = Relations.load(post)

    IO.inspect(post)

#     assert post.author.__struct__ = Author
#     assert post.author.id = 1
#     assert post.author.name = "PH"
  end
end
