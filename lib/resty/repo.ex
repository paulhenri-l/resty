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

  @spec first!(Resty.Resource.mod()) :: Resty.Resource.t() | nil
  @doc """
  Same as `first/1` but raise in case of error.
  """
  def first!(module) do
    case first(module) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec first(Resty.Resource.mod()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the first result returned by `all/1` or nil.
  """
  def first(module) do
    case all(module) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, [first | _]} -> {:ok, first}
    end
  end

  @spec last!(Resty.Resource.mod()) :: Resty.Resource.t() | nil
  @doc """
  Same as `last/1` but raise in case of error.
  """
  def last!(module) do
    case last(module) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec last(Resty.Resource.mod()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the last result returned by `all/1` or nil.
  """
  def last(module) do
    case all(module) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, collection} -> {:ok, List.last(collection)}
    end
  end

  @doc """
  Alias for `all/1`. Should be used with singular resource.
  """
  def show(module), do: all(module)
  def show!(module), do: all!(module)

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
  Return all the resources returned by the api.
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
  @doc """
  Same as `find/2` but raise in case of error.
  """
  def find!(module, id) do
    case find(module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec find(Resty.Resource.mod(), Resty.Resource.primary_key()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the matching resource for the given module and id or nil.
  """
  def find(module, id) do
    request = %Request{
      method: :get,
      url: Resource.url_for(module, id),
      headers: module.headers()
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @spec update_attribute!(Resty.Resource.t(), atom(), any()) :: Resty.Resource.t()
  @doc """
  Same as `update_attribute/3` but raise in case of error.
  """
  def update_attribute!(resource, key, value), do: update_attributes!(resource, [{key, value}])

  @spec update_attribute(Resty.Resource.t(), atom(), any()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Update the given resource's attribute.
  """
  def update_attribute(resource, key, value), do: update_attributes(resource, [{key, value}])

  @spec update_attributes!(Resty.Resource.t(), Keyword.t()) :: Resty.Resource.t()
  @doc """
  Same as `update_attributes/2` but raise in case of error.
  """
  def update_attributes!(resource, attributes) do
    case update_attributes(resource, attributes) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec update_attributes(Resty.Resource.t(), Keyword.t()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Update the given resource with the given list of attributes.
  """
  def update_attributes(resource, [{key, value} | next]) do
    Map.put(resource, key, value) |> update_attributes(next)
  end

  def update_attributes(resource, []) do
    # might be interesting to filter out unkown fields.
    resource |> save()
  end

  @spec save!(Resty.Resource.t()) :: Resty.Resource.t()
  @doc """
  Same as `save/1` but raise in case of error.
  """
  def save!(resource) do
    case save(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec save(Resty.Resource.t()) :: {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Persist the given resource, this will perform an UPDATE request if the resource already
  has an id, a POST request will be sent otherwise.
  """
  def save(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    save(resource, id)
  end

  defp save(resource = %{__struct__: module}, nil) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :post,
      url: Resource.url_for(module),
      headers: module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  defp save(resource = %{__struct__: module}, id) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :put,
      url: Resource.url_for(module, id),
      headers: module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @doc """
  Update without id. Should be used with singular resource.
  """
  def update(resource = %{__struct__: module}) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :put,
      url: Resource.url_for(module),
      headers: module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @spec delete!(Resty.Resource.t()) :: true
  @doc """
  Same as `delete/1` but raise in case of error.
  """
  def delete!(resource) do
    case delete(resource) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec delete!(Resty.Resource.mod(), Resty.Resource.primary_key()) :: true
  @doc """
  Same as `delete/2` but raise in case of error.
  """
  def delete!(module, id) do
    case delete(module, id) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec delete(Resty.Resource.t()) :: {:ok, true} | {:error, Exception.t()}
  @doc """
  Delete the given resource.
  """
  def delete(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    delete(resource.__struct__, id)
  end

  @spec delete(Resty.Resource.mod(), Resty.Resource.primary_key()) ::
          {:ok, true} | {:error, Exception.t()}
  @doc """
  Delete the resource matching the given module and id.
  """
  def delete(module, id) do
    request = %Request{
      method: :delete,
      url: Resource.url_for(module, id),
      headers: module.headers()
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, _} -> {:ok, true}
      {:error, _} = error -> error
    end
  end

  @spec exists?(Resty.Resource.t()) :: {:ok, boolean()} | {:error, Exception.t()}
  @doc """
  Does this resource exist on the remote api?
  """
  def exists?(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    exists?(resource.__struct__, id)
  end

  @spec exists?(Resty.Resource.mod(), Resty.Resource.primary_key()) ::
          {:ok, boolean()} | {:error, Exception.t()}
  @doc """
  Does a resource of the given type and id exist on the remote api?
  """
  def exists?(module, resource_id) do
    case find(module, resource_id) do
      {:ok, _} -> {:ok, true}
      {:error, %Resty.Error.ResourceNotFound{}} -> {:ok, false}
      {:error, _} = error -> error
    end
  end

  @spec reload!(Resty.Resource.t()) :: Resty.Resource.t()
  @doc """
  Same as `reload/1` but raise in case of error.
  """
  def reload!(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find!(resource.__struct__, id)
  end

  @spec reload(Resty.Resource.t()) :: {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Refresh the given resource with the latest data found on the remote api.
  """
  def reload(resource) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find(resource.__struct__, id)
  end
end
