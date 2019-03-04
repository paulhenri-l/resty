defmodule Resty.Repo do
  @moduledoc """
  This module is the one that will issue requests to the rest API and map
  responses to resource structs.
  """

  @type id_or_params :: Resty.Resource.url_parameters() | Resty.Resource.primary_key()

  alias Resty.Auth
  alias Resty.Request
  alias Resty.Resource
  alias Resty.Connection
  alias Resty.Serializer

  @spec first!(Resty.Resource.mod(), Resty.Resource.url_parameters()) :: Resty.Resource.t() | nil
  @doc """
  Same as `first/1` but raise in case of error.
  """
  def first!(module, url_parameters \\ []) do
    case first(module, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec first(Resty.Resource.mod(), Resty.Resource.url_parameters()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the first result returned by `all/1` or nil.
  """
  def first(module, url_parameters \\ []) do
    case all(module, url_parameters) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, [first | _]} -> {:ok, first}
    end
  end

  @spec last!(Resty.Resource.mod(), Resty.Resource.url_parameters()) :: Resty.Resource.t() | nil
  @doc """
  Same as `last/1` but raise in case of error.
  """
  def last!(module, url_parameters \\ []) do
    case last(module, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec last(Resty.Resource.mod(), Resty.Resource.url_parameters()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the last result returned by `all/1` or nil.
  """
  def last(module, url_parameters \\ []) do
    case all(module, url_parameters) do
      {:error, _} = error -> error
      {:ok, []} -> {:ok, nil}
      {:ok, collection} -> {:ok, List.last(collection)}
    end
  end

  @doc """
  Same as `all/1` but raise in case of error.
  """
  @spec all!(Resty.Resource.mod(), Resty.Resource.url_parameters()) :: [Resty.Resource.t()]
  def all!(module, url_parameters \\ []) do
    case all(module, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @doc """
  Return all the resources returned by the api.
  """
  @spec all(Resty.Resource.mod(), Resty.Resource.url_parameters()) ::
          {:ok, [Resty.Resource.t()]} | {:error, Exception.t()}
  def all(module, url_parameters \\ []) do
    request = %Request{
      method: :get,
      url: Resource.url_for(module, nil, url_parameters),
      headers: module.headers()
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @spec find!(Resty.Resource.mod(), Resty.Resource.primary_key(), Resty.Resource.url_parameters()) ::
          Resty.Resource.t() | nil
  @doc """
  Same as `find/2` but raise in case of error.
  """
  def find!(module, id, url_parameters \\ []) do
    case find(module, id, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec find(Resty.Resource.mod(), Resty.Resource.primary_key(), Resty.Resource.url_parameters()) ::
          {:ok, nil} | {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Return the matching resource for the given module and id or nil.
  """
  def find(module, id, url_parameters \\ []) do
    request = %Request{
      method: :get,
      url: Resource.url_for(module, id, url_parameters),
      headers: module.headers()
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  @spec update_attribute!(Resty.Resource.t(), atom(), any(), Resty.Resource.url_parameters()) ::
          Resty.Resource.t()
  @doc """
  Same as `update_attribute/3` but raise in case of error.
  """
  def update_attribute!(resource, key, value, url_parameters \\ []),
    do: update_attributes!(resource, [{key, value}], url_parameters)

  @spec update_attribute(Resty.Resource.t(), atom(), any(), Resty.Resource.url_parameters()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Update the given resource's attribute.
  """
  def update_attribute(resource, key, value, url_parameters \\ []),
    do: update_attributes(resource, [{key, value}], url_parameters)

  @spec update_attributes!(Resty.Resource.t(), Keyword.t(), Resty.Resource.url_parameters()) ::
          Resty.Resource.t()
  @doc """
  Same as `update_attributes/2` but raise in case of error.
  """
  def update_attributes!(resource, attributes, url_parameters \\ []) do
    case update_attributes(resource, attributes, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec update_attributes(Resty.Resource.t(), Keyword.t(), Resty.Resource.url_parameters()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Update the given resource with the given list of attributes.
  """
  def update_attributes(resource, new_attributes, url_parameters \\ [])

  def update_attributes(resource, [{key, value} | next], url_parameters) do
    Map.put(resource, key, value) |> update_attributes(next, url_parameters)
  end

  def update_attributes(resource, [], url_parameters) do
    # might be interesting to filter out unkown fields.
    resource |> save(url_parameters)
  end

  @spec save!(Resty.Resource.t(), Resty.Resource.url_parameters()) :: Resty.Resource.t()
  @doc """
  Same as `save/1` but raise in case of error.
  """
  def save!(resource, url_parameters \\ []) do
    case save(resource, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec save(Resty.Resource.t(), Resty.Resource.url_parameters()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Persist the given resource, this will perform an UPDATE request if the resource already
  has an id, a POST request will be sent otherwise.
  """
  def save(resource, url_parameters \\ []) do
    # Use get_primary_key instead of this. (here and everywhere else)
    id = Map.get(resource, resource.__struct__.primary_key())
    do_save(resource, id, url_parameters)
  end

  defp do_save(resource = %{__struct__: module}, nil, url_parameters) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :post,
      url: Resource.url_for(module, nil, url_parameters),
      headers: module.headers(),
      body: resource
    }

    case request |> Auth.authenticate(module) |> Connection.send(module) do
      {:ok, response} -> {:ok, Serializer.deserialize(response, module)}
      {:error, _} = error -> error
    end
  end

  defp do_save(resource = %{__struct__: module}, id, url_parameters) do
    resource = resource |> Serializer.serialize()

    request = %Request{
      method: :put,
      url: Resource.url_for(module, id, url_parameters),
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
    id = Resty.Resource.get_primary_key(resource)
    delete!(resource.__struct__, id, [])
  end

  @spec delete!(Resty.Resource.t(), id_or_params) :: true
  @doc """
  Same as `delete/2` but raise in case of error.
  """
  def delete!(resource, url_parameters) when is_map(url_parameters) do
    id = Resty.Resource.get_primary_key(resource)
    delete!(resource.__struct__, id, url_parameters)
  end

  def delete!(module, id) do
    delete!(module, id, [])
  end

  @spec delete!(
          Resty.Resource.mod(),
          Resty.Resource.primary_key(),
          Resty.Resource.url_parameters()
        ) :: true
  @doc """
  Same as `delete/3` but raise in case of error.
  """
  def delete!(module, id, url_parameters) do
    case delete(module, id, url_parameters) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @spec delete(Resty.Resource.t()) :: {:ok, true} | {:error, Exception.t()}
  @doc """
  Delete the given resource.
  """
  def delete(resource) do
    id = Resty.Resource.get_primary_key(resource)
    delete(resource.__struct__, id, [])
  end

  @spec delete(Resty.Resource.t(), id_or_params) :: {:ok, true} | {:error, Exception.t()}
  @doc """
  Delete the given resource.
  """
  def delete(resource, url_parameters) when is_list(url_parameters) do
    id = Resty.Resource.get_primary_key(resource)
    delete(resource.__struct__, id, url_parameters)
  end

  def delete(resource_module, id) do
    delete(resource_module, id, [])
  end

  @spec delete(
          Resty.Resource.mod(),
          Resty.Resource.primary_key(),
          Resty.Resource.url_parameters()
        ) ::
          {:ok, true} | {:error, Exception.t()}
  @doc """
  Delete the resource matching the given module and id.
  """
  def delete(module, id, url_parameters) do
    request = %Request{
      method: :delete,
      url: Resource.url_for(module, id, url_parameters),
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
    exists?(resource.__struct__, id, [])
  end

  @spec exists?(Resty.Resource.t(), id_or_params) :: {:ok, boolean()} | {:error, Exception.t()}
  @doc """
  Does this resource exist on the remote api?
  """
  def exists?(resource, url_parameters) when is_map(url_parameters) do
    id = Map.get(resource, resource.__struct__.primary_key())
    exists?(resource.__struct__, id, url_parameters)
  end

  def exists?(module, id) do
    exists?(module, id, [])
  end

  @spec exists?(
          Resty.Resource.mod(),
          Resty.Resource.primary_key(),
          Resty.Resource.url_parameters()
        ) ::
          {:ok, boolean()} | {:error, Exception.t()}
  @doc """
  Does a resource of the given type and id exist on the remote api?
  """
  def exists?(module, resource_id, url_parameters) do
    case find(module, resource_id, url_parameters) do
      {:ok, _} -> {:ok, true}
      {:error, %Resty.Error.ResourceNotFound{}} -> {:ok, false}
      {:error, _} = error -> error
    end
  end

  @spec reload!(Resty.Resource.t(), Resty.Resource.url_parameters()) :: Resty.Resource.t()
  @doc """
  Same as `reload/1` but raise in case of error.
  """
  def reload!(resource, url_parameters \\ []) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find!(resource.__struct__, id, url_parameters)
  end

  @spec reload(Resty.Resource.t(), Resty.Resource.url_parameters()) ::
          {:ok, Resty.Resource.t()} | {:error, Exception.t()}
  @doc """
  Refresh the given resource with the latest data found on the remote api.
  """
  def reload(resource, url_parameters \\ []) do
    id = Map.get(resource, resource.__struct__.primary_key())
    find(resource.__struct__, id, url_parameters)
  end
end
