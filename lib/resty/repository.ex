defmodule Resty.Repository do
  @adapter Application.get_env(:resty, :adapter, Resty.Adapters.HTTPoison)

  def find(resource_module, id) do
    response = resource_module.path(id) |> adapter().get!(headers())

    resource_module.from_json(response)
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource_module, resource = %{id: nil}) do
    resource = resource |> resource_module.to_json()

    response = resource_module.path() |> adapter().post!(resource, headers())

    resource_module.from_json(response)
  end

  def save(resource_module, resource) do
    resource = resource |> resource_module.to_json()

    response = resource_module.path() |> adapter().put!(resource, headers())

    resource_module.from_json(response)
  end

  def adapter, do: @adapter

  defp headers do
    [
      Accept: "application/json",
      "Content-Type": "application/json"
    ]
  end
end
