defmodule Fakes.TestConnection do
  alias Fakes.TestDB

  @resources [
    {Fakes.Post, "posts"},
    {Fakes.PostWithRelations, "posts-with-relations"}
  ]

  @moduledoc false

  for {module, path} <- @resources do
    def send(%{method: :get, url: "site.tld/" <> unquote(path)}, _) do
      case TestDB.get(unquote(module), :all) do
        nil -> {:error, Resty.Error.ResourceNotFound.new()}
        resource -> {:ok, resource}
      end
    end

    def send(%{method: :get, url: "site.tld/" <> unquote(path) <> "/" <> id}, _) do
      case TestDB.get(unquote(module), id) do
        nil -> {:error, Resty.Error.ResourceNotFound.new()}
        resource -> {:ok, resource}
      end
    end

    def send(%{method: :post, url: "site.tld/" <> unquote(path), body: body}, _) do
      case TestDB.insert(unquote(module), body) do
        nil -> {:error, Resty.Error.ServerError.new()}
        resource -> {:ok, resource}
      end
    end

    def send(%{method: :put, url: "site.tld/" <> unquote(path) <> "/" <> _id, body: body}, _) do
      case TestDB.put(unquote(module), body) do
        nil -> {:error, Resty.Error.ServerError.new()}
        resource -> {:ok, resource}
      end
    end

    def send(%{method: :delete, url: "site.tld/" <> unquote(path) <> "/" <> id}, _) do
      {:ok, TestDB.delete(unquote(module), id)}
    end
  end

  def send(%{url: "site.tld/empty"}, _) do
    {:ok, "[]"}
  end

  def send(%{url: "site.tld/bad-request" <> _}, _) do
    {:error, Resty.Error.BadRequest.new(message: "Bad request")}
  end

  def send(%{url: "site.tld/invalid" <> _}, _) do
    {:error, Resty.Error.ResourceInvalid.new(message: "Invalid")}
  end

  def send(_, _) do
    {:error, Resty.Error.ResourceNotFound.new(message: "Not found")}
  end
end
