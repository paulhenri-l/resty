defmodule Fakes.TestConnection do
  alias Fakes.Post
  alias Fakes.TestDB

  @moduledoc false

  def send(%{method: :get, url: "site.tld/posts"}) do
    case TestDB.get(Post, :all) do
      nil -> {:error, Resty.Error.ResourceNotFound.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :get, url: "site.tld/posts/" <> id}) do
    case TestDB.get(Post, id) do
      nil -> {:error, Resty.Error.ResourceNotFound.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :post, url: "site.tld/posts", body: body}) do
    case TestDB.insert(Post, body) do
      nil -> {:error, Resty.Error.ServerError.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :put, url: "site.tld/posts/" <> _id, body: body}) do
    case TestDB.put(Post, body) do
      nil -> {:error, Resty.Error.ServerError.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :delete, url: "site.tld/posts/" <> id}) do
    {:ok, TestDB.delete(Post, id)}
  end

  def send(%{url: "site.tld/bad-request" <> _}) do
    {:error, Resty.Error.BadRequest.new(message: "Bad request")}
  end

  def send(%{url: "site.tld/invalid" <> _}) do
    {:error, Resty.Error.ResourceInvalid.new(message: "Invalid")}
  end

  def send(_) do
    {:error, Resty.Error.ResourceNotFound.new(message: "Not found")}
  end
end
