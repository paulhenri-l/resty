defmodule Fakes.TestAdapter do
  alias Fakes.Post
  alias Fakes.TestDB

  @behaviour Resty.Adapter

  def get!("site.tld/posts/" <> id, _) do
    TestDB.get(Post, String.to_integer(id))
  end

  def head!(_, _), do: ""

  def post!("site.tld/posts", body, _) do
    TestDB.insert(Post, body)
  end

  def post!(_, _, _), do: ""

  def patch!(_, _, _), do: ""

  def put!("site.tld/posts", body, _) do
    TestDB.put(Post, body)
  end

  def put!(_, _, _), do: ""

  def delete!("site.tld/posts/" <> id, _) do
    TestDB.delete(Post, String.to_integer(id))
  end

  def delete!(_, _), do: ""
end
