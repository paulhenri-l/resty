defmodule Resty.Repo do
  @moduledoc """
  This module is the one that will issue requests to the rest API and map
  responses to resource structs.
  """

  alias Resty.Auth
  alias Resty.Request
  alias Resty.Resource
  alias Resty.Connection
  alias Resty.Serializer

  def first(resource_module), do: find(resource_module, :first)

  def first!(resource_module), do: find!(resource_module, :first)

  def last(resource_module), do: find(resource_module, :last)

  def last!(resource_module), do: find!(resource_module, :last)

  def all(resource_module), do: find(resource_module, :all)

  def all!(resource_module), do: find!(resource_module, :all)

  def find(resource_module, :first) do
    case find(resource_module, :all) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, [first | _]} -> {:ok, first}
    end
  end

  def find(resource_module, :last) do
    case find(resource_module, :all) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, collection} -> {:ok, List.last(collection)}
    end
  end

  def find(resource_module, :all) do
    request = %Request{
      method: :get,
      url: Resource.url_for(resource_module),
      headers: resource_module.headers()
    }

    case request |> Auth.authenticate(resource_module) |> Connection.send(resource_module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, resource_module)}
      {:error, _} = error -> error
    end
  end

  def find(resource_module, id) do
    request = %Request{
      method: :get,
      url: Resource.url_for(resource_module, id),
      headers: resource_module.headers()
    }

    case request |> Auth.authenticate(resource_module) |> Connection.send(resource_module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, resource_module)}
      {:error, _} = error -> error
    end
  end

  def find!(resource_module, id) do
    case find(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def update_attribute(resource, key, value), do: update_attributes(resource, [{key, value}])

  def update_attribute!(resource, key, value), do: update_attributes!(resource, [{key, value}])

  def update_attributes(resource, [{key, value} | next]) do
    Map.put(resource, key, value) |> update_attributes(next)
  end

  def update_attributes(resource, []) do
    # might be interesting to filter out unkown fields.
    resource |> save()
  end

  def update_attributes!(resource, attributes) do
    case update_attributes(resource, attributes) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def save(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    save(resource, id)
  end

  defp save(resource = %{__struct__: resource_module}, nil) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :post,
      url: Resource.url_for(resource_module),
      headers: resource_module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(resource_module) |> Connection.send(resource_module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, resource_module)}
      {:error, _} = error -> error
    end
  end

  defp save(resource = %{__struct__: resource_module}, id) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :put,
      url: Resource.url_for(resource_module, id),
      headers: resource_module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(resource_module) |> Connection.send(resource_module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, resource_module)}
      {:error, _} = error -> error
    end
  end

  def save!(resource) do
    case save(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def delete(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    delete(resource.__struct__, id)
  end

  def delete(resource_module, id) do
    request = %Request{
      method: :delete,
      url: Resource.url_for(resource_module, id),
      headers: resource_module.headers()
    }

    case request |> Auth.authenticate(resource_module) |> Connection.send(resource_module) do
      {:ok, _} -> {:ok, true}
      {:error, _} = error -> error
    end
  end

  def delete!(resource) do
    case delete(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def delete!(resource_module, id) do
    case delete(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  def exists?(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    exists?(resource.__struct__, id)
  end

  def exists?(resource_module, resource_id) do
    case find(resource_module, resource_id) do
      {:ok, _} -> {:ok, true}
      {:error, %Resty.Error.ResourceNotFound{}} -> {:ok, false}
      {:error, _} = error -> error
    end
  end

  def reload(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find(resource.__struct__, id)
  end

  def reload!(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find!(resource.__struct__, id)
  end
end
