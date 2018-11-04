defmodule Resty.Repository do
  @connection Application.get_env(:resty, :connection, Resty.Connections.HTTPoison)

  def find(resource_module, id) do
    response = resource_module.path(id) |> connection().get!(headers())

    case response do
      nil -> nil
      response -> resource_module.from_json(response)
    end
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource_module, resource = %{id: nil}) do
    resource = resource |> resource_module.to_json()

    response = resource_module.path() |> connection().post!(resource, headers())

    resource_module.from_json(response)
  end

  def save(resource_module, resource) do
    resource = resource |> resource_module.to_json()

    response = resource_module.path() |> connection().put!(resource, headers())

    resource_module.from_json(response)
  end

  def delete(resource), do: delete(resource.__module__, resource)

  def delete(resource_module, resource) do
    resource_module.path(resource) |> connection().delete!(headers())
  end

  def connection, do: @connection

  defp headers do
    [
      Accept: "Application/json; Charset=utf-8",
      "Content-Type": "application/json"
    ]
  end
end
