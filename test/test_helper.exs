# When using travis, run tests with this command:
# mix test --include external:true

defmodule MockedConnection do
  use Resty.Connection.Mock

  @ph %{id: 1, name: "PH"}
  @hp %{id: 3, name: "HP"}

  @ph_address %{id: 1, author_id: 1, city: "Somewhere"}
  @phl_address %{id: 2, author_id: 4, city: "Another somewhere"}

  @phl %{id: 4, name: "PHL", address: @phl_address}

  @first_post %{id: 1, name: "First Post", body: "lorem ipsum", author_id: 1}
  @second_post %{
    id: 2,
    name: "Second Post",
    body: "lorem ipsum",
    author_id: 1,
    comments: [%{id: 4, post_id: 2, body: "A comment"}]
  }
  @third_post %{id: 3, name: "Third Post", body: "lorem ipsum", author_id: 1}
  @fourth_post %{id: 4, name: "Fourth Post", body: "lorem ipsum", author_id: 2}

  @comment1 %{id: 1, post_id: 1, body: "My first comment"}
  @comment2 %{id: 2, post_id: 1, body: "My second comment"}
  @comment3 %{id: 3, post_id: 1, body: "My third comment"}
  @first_post_comments [@comment1, @comment2, @comment3] |> Jason.encode!()

  @posts [@first_post, @second_post, @third_post, @fourth_post] |> Jason.encode!()

  # Posts
  mock(:get, "site.tld/posts", {:ok, @posts})
  mock(:get, "site.tld/posts/1", {:ok, @first_post |> Jason.encode!()})
  mock(:get, "site.tld/posts/1?query_param=some-value", {:ok, @first_post |> Jason.encode!()})
  mock(:get, "site.tld/posts/2", {:ok, @second_post |> Jason.encode!()})
  mock(:get, "site.tld/posts/3", {:ok, @third_post |> Jason.encode!()})
  mock(:get, "site.tld/posts/4", {:ok, @fourth_post |> Jason.encode!()})
  mock(:post, "site.tld/posts")
  mock(:put, "site.tld/posts/1")
  mock(:put, "site.tld/posts/4")
  mock(:put, "site.tld/posts/2", {:error, Resty.Error.ResourceInvalid.new()})
  mock(:delete, "site.tld/posts/1")
  mock(:delete, "site.tld/posts/1?query_param=some-value")
  mock(:delete, "site.tld/posts/2", {:error, Resty.Error.ForbiddenAccess.new()})

  # Posts/Comments
  mock(:get, "site.tld/posts/1/comments", {:ok, @first_post_comments})
  mock(:get, "site.tld/posts/2/comments", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:get, "site.tld/posts/3/comments", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:get, "site.tld/posts/4/comments", {:ok, "[]"})

  # Authors
  mock(:get, "site.tld/authors/1", {:ok, @ph |> Jason.encode!()})
  mock(:get, "site.tld/authors/1/address", {:ok, @ph_address |> Jason.encode!()})
  mock(:get, "site.tld/authors/2", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:get, "site.tld/authors/3", {:ok, @hp |> Jason.encode!()})
  mock(:get, "site.tld/authors/3/address", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:get, "site.tld/authors/4", {:ok, @phl |> Jason.encode!()})
  mock(:get, "site.tld/authors/4/address", {:error, Resty.Error.ResourceNotFound.new()})

  # Subscribers
  mock(:get, "site.tld/subscribers", {:ok, "[]"})
  mock(:get, "site.tld/subscribers/1", {:error, Resty.Error.ResourceNotFound.new()})

  # Likes
  mock(:get, "site.tld/likes", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:get, "site.tld/likes/1", {:error, Resty.Error.ResourceNotFound.new()})
  mock(:post, "site.tld/likes", {:error, Resty.Error.ResourceNotFound.new()})

  # Admins
  mock(:get, "site.tld/admins/1.json", {:error, Resty.Error.ForbiddenAccess.new()})
end

ExUnit.configure(exclude: [external: true])
ExUnit.start()
