defmodule Fakes.TestConnection do
  alias Fakes.Post
  alias Fakes.TestDB

  @moduledoc false
  @behaviour Resty.Connection
  @invalid_post Post.invalid() |> Resty.Resource.Serializer.serialize()

  def send(%{method: :get, url: "site.tld/posts/bad-request"}) do
    {:error, Resty.Error.BadRequest.new()}
  end

  def send(%{method: :get, url: "site.tld/posts/" <> id}) do
    case TestDB.get(Post, id) do
      nil -> {:error, Resty.Error.ResourceNotFound.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :post, url: "site.tld/posts", body: @invalid_post}) do
    {:error, %Resty.Error.ResourceInvalid{}}
  end

  def send(%{method: :post, url: "site.tld/posts", body: body}) do
    case TestDB.insert(Post, body) do
      nil -> {:error, Resty.Error.ServerError.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :put, url: "site.tld/posts/non_existent"}) do
    {:error, Resty.Error.ResourceNotFound.new()}
  end

  def send(%{method: :put, url: "site.tld/posts/" <> _id, body: body}) do
    case TestDB.put(Post, body) do
      nil -> {:error, Resty.Error.ServerError.new()}
      resource -> {:ok, resource}
    end
  end

  def send(%{method: :delete, url: "site.tld/posts/non_existent"}) do
    {:error, Resty.Error.ResourceNotFound.new()}
  end

  def send(%{method: :delete, url: "site.tld/posts/" <> id}) do
    {:ok, TestDB.delete(Post, id)}
  end

  def send(_) do
    {:error, Resty.Error.ResourceNotFound.new(message: "Not found")}
  end
end
