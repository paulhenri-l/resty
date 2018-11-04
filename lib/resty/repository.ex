defmodule Resty.Repository do
  alias Resty.Request
  @connection Application.get_env(:resty, :connection, Resty.Connections.HTTPoison)

  # We'll have to add bang methods
  # regular methods will then return tuples

  def find(resource_module, id) do
    request = %Request{method: :get, url: resource_module.path(id), headers: headers()}

    case request |> connection().send() do
      {:error, _} -> nil
      {:ok, response} -> resource_module.from_json(response)
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
      {:error, _} -> nil
      {:ok, response} -> resource_module.from_json(response)
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
      {:error, _} -> nil
      {:ok, response} -> resource_module.from_json(response)
    end
  end

  def delete(resource), do: delete(resource.__module__, resource)

  def delete(resource_module, resource = %{id: id}) do
    request = %Request{
      method: :delete,
      url: resource_module.path(id),
      headers: headers(),
      body: resource
    }

    case request |> connection().send() do
      {:error, _} -> nil
      {:ok, _} -> true
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
