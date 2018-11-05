defmodule Resty.Repository do
  alias Resty.Request
  @connection Application.get_env(:resty, :connection, Resty.Connections.HTTPoison)

  def find!(resource_module, id) do
    case find(resource_module, id) do
      {:error, error} -> raise error
      {:ok, response} -> response
    end
  end

  def find(resource_module, id) do
    request = %Request{method: :get, url: resource_module.path(id), headers: headers()}

    case request |> connection().send() do
      {:error, _} = error -> error
      {:ok, response} -> {:ok, resource_module.from_json(response)}
    end
  end

  def save!(resource), do: save!(resource.__module__, resource)

  def save!(resource_module, resource) do
    case save(resource_module, resource) do
      {:error, error} -> raise error
      {:ok, response} -> response
    end
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource_module, resource = %{id: nil}) do
    resource = resource |> resource_module.to_json()

    request = %Request{
      method: :post,
      url: resource_module.path(),
      headers: headers(),
      body: resource
    }

    case request |> connection().send() do
      {:error, _} = error -> error
      {:ok, response} -> {:ok, resource_module.from_json(response)}
    end
  end

  def save(resource_module, resource = %{id: id}) do
    resource = resource |> resource_module.to_json()

    request = %Request{
      method: :put,
      url: resource_module.path(id),
      headers: headers(),
      body: resource
    }

    case request |> connection().send() do
      {:error, _} = error -> error
      {:ok, response} -> {:ok, resource_module.from_json(response)}
    end
  end

  def delete!(resource), do: delete!(resource.__module__, resource)

  def delete!(resource_module, resource) do
    case delete(resource_module, resource) do
      {:error, error} -> raise error
      {:ok, response} -> response
    end
  end

  def delete(resource), do: delete(resource.__module__, resource)

  def delete(resource_module, %{id: id}) do
    request = %Request{
      method: :delete,
      url: resource_module.path(id),
      headers: headers()
    }

    case request |> connection().send() do
      {:error, _} = error -> error
      {:ok, _} -> {:ok, true}
    end
  end

  def connection, do: @connection

  defp headers do
    [
      Accept: "Application/json; Charset=utf-8",
      "Content-Type": "application/json"
    ]
  end
end
