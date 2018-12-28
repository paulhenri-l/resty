defmodule Resty.Repo do
  @moduledoc """
  This module is the one that will issue requests to the rest API and map
  responses to resource structs.
  """

  @typedoc """
  Special values used in order to make find behave differently.
  """
  @type special_find_key() :: :first | :last

  alias Resty.Auth
  alias Resty.Request
  alias Resty.Resource
  alias Resty.Connection
  alias Resty.Serializer

  @spec first!(Resty.Resource.mod()) :: Resty.Resource.t() | nil
  def first!(resource_module), do: find!(resource_module, :first)

  @spec first(Resty.Resource.mod()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def first(resource_module), do: find(resource_module, :first)

  @spec last!(Resty.Resource.mod()) :: Resty.Resource.t() | nil
  def last!(resource_module), do: find!(resource_module, :last)

  @spec last(Resty.Resource.mod()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def last(resource_module), do: find(resource_module, :last)

  @doc """
  Same as `all/1` but raise in case of error.
  """
  @spec all!(Resty.Resource.mod()) :: [Resty.Resource.t()]
  def all!(module) do
    case all(module) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @doc """
  """
  @spec all(Resty.Resource.mod()) :: {:ok, [Resty.Resource.t()]} | {:error, Exception.t()}
  def all(module) do
    request = %Request{
      method: :get,
      url: Resource.url_for(module),
      headers: module.headers()
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @spec find!(Resty.Resource.mod(), Resty.Resource.primary_key()) :: Resty.Resource.t() | nil
  def find!(resource_module, id) do
    case find(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec find(Resty.Resource.mod(), Resty.Resource.primary_key() | special_find_key()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def find(resource_module, :first) do
    case all(resource_module) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, [first | _]} -> {:ok, first}
    end
  end

  def find(resource_module, :last) do
    case all(resource_module) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, collection} -> {:ok, List.last(collection)}
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

  @spec update_attribute!(Resty.Resource.t(), atom(), any()) :: Resty.Resource.t()
  def update_attribute!(resource, key, value), do: update_attributes!(resource, [{key, value}])

  @spec update_attribute(Resty.Resource.t(), atom(), any()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def update_attribute(resource, key, value), do: update_attributes(resource, [{key, value}])

  @spec update_attributes!(Resty.Resource.t(), Keyword.t()) :: Resty.Resource.t()
  def update_attributes!(resource, attributes) do
    case update_attributes(resource, attributes) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec update_attributes(Resty.Resource.t(), Keyword.t()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def update_attributes(resource, [{key, value} | next]) do
    Map.put(resource, key, value) |> update_attributes(next)
  end

  def update_attributes(resource, []) do
    # might be interesting to filter out unkown fields.
    resource |> save()
  end

  @spec save!(Resty.Resource.t()) :: Resty.Resource.t()
  def save!(resource) do
    case save(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec save(Resty.Resource.t()) :: {:ok, Resty.Resource.t()} | {:error, nil}
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

  @spec delete!(Resty.Resource.t()) :: true
  def delete!(resource) do
    case delete(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec delete!(Resty.Resource.mod(), Resty.Resource.primary_key()) :: true
  def delete!(resource_module, id) do
    case delete(resource_module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec delete(Resty.Resource.t()) :: {:ok, true} | {:error, Exception.t()}
  def delete(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    delete(resource.__struct__, id)
  end

  @spec delete(Resty.Resource.mod(), Resty.Resource.primary_key()) ::
          {:ok, true} | {:error, Exception.t()}
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

  @spec exists?(Resty.Resource.t()) :: {:ok, boolean()} | {:error, Exception.t()}
  def exists?(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    exists?(resource.__struct__, id)
  end

  @spec exists?(Resty.Resource.mod(), Resty.Resource.primary_key()) ::
          {:ok, boolean()} | {:error, Exception.t()}
  def exists?(resource_module, resource_id) do
    case find(resource_module, resource_id) do
      {:ok, _} -> {:ok, true}
      {:error, %Resty.Error.ResourceNotFound{}} -> {:ok, false}
      {:error, _} = error -> error
    end
  end

  @spec reload!(Resty.Resource.t()) :: Resty.Resource.t()
  def reload!(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find!(resource.__struct__, id)
  end

  @spec reload(Resty.Resource.t()) :: {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  def reload(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find(resource.__struct__, id)
  end
end
