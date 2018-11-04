defmodule Fakes.TestConnection do
  alias Fakes.Post
  alias Fakes.TestDB

  @behaviour Resty.Connection

  def send(%{method: :get, url: "site.tld/posts/" <> id}) do
    {:ok, TestDB.get(Post, String.to_integer(id))}
  end

  def send(%{method: :post, url: "site.tld/posts", body: body}) do
    {:ok, TestDB.insert(Post, body)}
  end

  def send(%{method: :put, url: "site.tld/posts/" <> _id, body: body}) do
    {:ok, TestDB.put(Post, body)}
  end

  def send(%{method: :delete, url: "site.tld/posts/" <> id}) do
    {:ok, TestDB.delete(Post, String.to_integer(id))}
  end

  def send(_) do
    {:error, Resty.Error.ResourceNotFound.new(message: "Not found")}
  end
end
