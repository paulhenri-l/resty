defmodule Resty.Repository do
  def find(resource, id) do
    response = resource.path(id) |> adapter().get!(headers())

    resource.from_json(response)
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource, data) do
    data = data |> resource.to_json()

    response = resource.path() |> adapter().post!(data, headers())

    resource.from_json(response)
  end

  def adapter do
    Resty.Adapters.HTTPoison
  end

  defp headers do
    [
      Accept: "application/json",
      "Content-Type": "application/json"
    ]
  end
end
