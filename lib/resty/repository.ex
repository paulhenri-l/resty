defmodule Resty.Repository do
  alias Resty.Request
  alias Resty.Resource.Path

  @connection Application.get_env(:resty, :connection, Resty.Connections.HTTPoison)

  # Add spec and rename to module.
  def find!(resource_module, id) do
    case find(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def find(resource_module, id) do
    request = %Request{method: :get, url: Path.to(resource_module, id), headers: headers()}

    case request |> connection().send() do
      {:ok, response} -> {:ok, resource_module.from_json(response)}
      {:error, _} = error -> error
    end
  end

  def exists?(resource), do: exists?(resource.__module__, resource.id)

  def exists?(resource_module, resource_id) do
    case find(resource_module, resource_id) do
      {:ok, _} -> {:ok, true}
      {:error, %Resty.Error.ResourceNotFound{}} -> {:ok, false}
      {:error, _} = error -> error
    end
  end

  def save!(resource), do: save!(resource.__module__, resource)

  def save!(resource_module, resource) do
    case save(resource_module, resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource_module, resource = %{id: nil}) do
    resource = resource |> resource_module.to_json()

    request = %Request{
      method: :post,
      url: Path.to(resource_module),
      headers: headers(),
      body: resource
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, resource_module.from_json(response)}
      {:error, _} = error -> error
    end
  end

  def save(resource_module, resource = %{id: id}) do
    resource = resource |> resource_module.to_json()

    request = %Request{
      method: :put,
      url: Path.to(resource_module, id),
      headers: headers(),
      body: resource
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, resource_module.from_json(response)}
      {:error, _} = error -> error
    end
  end

  def delete!(resource), do: delete!(resource.__module__, resource)

  def delete!(resource_module, resource) do
    case delete(resource_module, resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def delete(resource), do: delete(resource.__module__, resource)

  def delete(resource_module, %{id: id}) do
    request = %Request{
      method: :delete,
      url: Path.to(resource_module, id),
      headers: headers()
    }

    case request |> connection().send() do
      {:ok, _} -> {:ok, true}
      {:error, _} = error -> error
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

# Logging
# Reload
# Destroy or Delete?
# Update(resource, field, value)
# Update(resource, fields)

# Here or on resource?
# Clone
# Persisted?
# Custom id field
# Encode
