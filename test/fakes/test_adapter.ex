defmodule Fakes.TestAdapter do
  alias Fakes.Post

  @behaviour Resty.Adapter

  def get!("site.tld/posts/" <> id, _) do
    Fakes.TestDB.get(Post, String.to_integer(id))
    |> Post.to_json()
  end

  def head!(_, _), do: ""

  def post!("site.tld/posts", body, _) do
    post =
      body
      |> Post.from_json()

    Fakes.TestDB.put(Post, post)
    |> Post.to_json()
  end

  def post!(_, _, _), do: ""

  def patch!(_, _, _), do: ""

  def put!("site.tld/posts", body, _) do
    post =
      body
      |> Post.from_json()

    Fakes.TestDB.update(Post, post)
    |> Post.to_json()
  end

  def put!(_, _, _), do: ""

  def delete!(_, _), do: ""
end
