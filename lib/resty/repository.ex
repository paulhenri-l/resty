defmodule Resty.Repository do
  def find(resource, id) do
    response = resource.path(id) |> HTTPoison.get!(headers())

    resource.from_json(response.body)
  end

  def save(resource), do: save(resource.__module__, resource)

  def save(resource, data) do
    data = data |> resource.to_json()

    response = resource.path() |> HTTPoison.post!(data, headers())

    resource.from_json(response.body)
  end

  defp headers do
    [
      Accept: "application/json",
      "Content-Type": "application/json"
    ]
  end
end
