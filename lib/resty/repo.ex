defmodule Resty.Repo do
  alias Resty.Request
  alias Resty.Resource.Path
  alias Resty.Serializer

  @connection Resty.default_connection()

  def first(module), do: find(module, :first)
  def first!(module), do: find!(module, :first)

  def last(module), do: find(module, :last)
  def last!(module), do: find!(module, :last)

  def all(module), do: find(module, :all)
  def all!(module), do: find!(module, :all)

  def find!(resource_module, id) do
    case find(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def find(resource_module, :first) do
    case find(resource_module, :all) do
      {:error, _} = error -> error
      {:ok, [first | _]} -> {:ok, first}
    end
  end

  def find(resource_module, :last) do
    case find(resource_module, :all) do
      {:error, _} = error -> error
      {:ok, collection} -> {:ok, List.last(collection)}
    end
  end

  def find(resource_module, :all) do
    request = %Request{
      method: :get,
      url: Path.to(resource_module),
      headers: resource_module.headers()
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, Serializer.deserialize(resource_module, response)}
      {:error, _} = error -> error
    end
  end

  def find(resource_module, id) do
    request = %Request{
      method: :get,
      url: Path.to(resource_module, id),
      headers: resource_module.headers()
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, Serializer.deserialize(resource_module, response)}
      {:error, _} = error -> error
    end
  end

  def update_attribute(resource, key, value), do: update_attributes(resource, [{key, value}])
  def update_attribute!(resource, key, value), do: update_attributes!(resource, [{key, value}])

  def update_attributes!(resource, attributes) do
    case update_attributes(resource, attributes) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def update_attributes(resource, [{key, value} | next]) do
    Map.put(resource, key, value) |> update_attributes(next)
  end

  def update_attributes(resource, []) do
    # might be interesting to filter out unkown fields.
    resource |> save()
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
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :post,
      url: Path.to(resource_module),
      headers: resource_module.headers(),
      body: resource
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, Serializer.deserialize(resource_module, response)}
      {:error, _} = error -> error
    end
  end

  def save(resource_module, resource = %{id: id}) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :put,
      url: Path.to(resource_module, id),
      headers: resource_module.headers(),
      body: resource
    }

    case request |> connection().send() do
      {:ok, response} -> {:ok, Serializer.deserialize(resource_module, response)}
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
    delete(resource_module, id)
  end

  def delete(resource_module, id) do
    request = %Request{
      method: :delete,
      url: Path.to(resource_module, id),
      headers: resource_module.headers()
    }

    case request |> connection().send() do
      {:ok, _} -> {:ok, true}
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

  def reload(resource), do: find(resource.__module__, resource.id)
  def reload!(resource), do: find!(resource.__module__, resource.id)

  def connection, do: @connection
end
