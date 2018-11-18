defmodule Resty.Resource do
  @moduledoc """
  This module provides a few functions to work with resource structs. Resource
  structs are created thanks to the `Resty.Resource.Base` module.
  """

  @typedoc """
  A resource struct (also called a resource).
  """
  @type t() :: struct()

  @typedoc """
  A resource module.

  For the resource `%Post{}` the resource module would be `Post`
  """
  @type mod() :: module()

  @typedoc """
  A resource primary key.
  """
  @type primary_key() :: any()

  @doc """
  Clone the given resource

  This will create a new resource struct from the given one. The new struct
  will be marked as not persisted and will not have an id.

  *This is not deep cloning. If there are relations their ids and persisted
  states won't be updated.*

  ```
  iex> Fakes.Post
  ...> |> Resty.Repo.first!()
  ...> |> Resty.Resource.clone()
  %Fakes.Post{id: nil, name: "test1"}
  ```
  """
  def clone(resource), do: clone(resource.__struct__, resource)

  defp clone(resource_module, resource) do
    resource
    |> Map.take(resource_module.known_attributes())
    |> Map.delete(resource_module.primary_key())
    |> resource_module.build()
  end

  @doc """
  Is the given resource new? (not persisted)

  ```
  iex> Fakes.Post.build()
  ...> |> Resty.Resource.new?()
  true

  iex> Fakes.Post.build()
  ...> |> Resty.Repo.save!()
  ...> |> Resty.Resource.new?()
  false
  ```
  """
  def new?(resource), do: !persisted?(resource)

  @doc """
  Has the given resource been persisted?

  ```
  iex> Fakes.Post.build()
  ...> |> Resty.Resource.persisted?()
  false

  iex> Fakes.Post.build()
  ...> |> Resty.Repo.save!()
  ...> |> Resty.Resource.persisted?()
  true
  ```
  """
  def persisted?(resource)
  def persisted?(%{__persisted__: persisted}), do: persisted

  @doc """
  Build a URL to the resource.

  ```
  iex> Fakes.Post |> Resty.Resource.url_for()
  "site.tld/posts"

  iex> Fakes.Post.build(id: 1) |> Resty.Resource.url_for()
  "site.tld/posts/1"
  ```
  """
  def url_for(module_or_resource)

  def url_for(resource_module) when is_atom(resource_module) do
    url_for(resource_module, [])
  end

  def url_for(resource) when is_map(resource) do
    resource_module = resource.__struct__
    id = Map.get(resource, resource_module.primary_key())
    url_for(resource_module, id)
  end

  @doc """
  Build a URL to the resource.

  ```
  iex> Fakes.Post |> Resty.Resource.url_for(key: "value")
  "site.tld/posts?key=value"

  iex> Fakes.Post.build(id: 1) |> Resty.Resource.url_for(key: "value")
  "site.tld/posts/1?key=value"

  iex> Fakes.Post |> Resty.Resource.url_for("slug")
  "site.tld/posts/slug"
  ```
  """
  def url_for(module_or_resource, id_or_params)

  def url_for(resource_module, params) when is_atom(resource_module) and is_list(params) do
    url_for(resource_module, nil, params)
  end

  def url_for(resource, params) when is_map(resource) and is_list(params) do
    resource_module = resource.__struct__
    id = Map.get(resource, resource_module.primary_key())
    url_for(resource_module, id, params)
  end

  def url_for(resource_module, id) when is_atom(resource_module) do
    url_for(resource_module, id, [])
  end

  @doc """
  Build a URL to the resource.

  ```
  iex> Fakes.Post |> Resty.Resource.url_for("slug", key: "value")
  "site.tld/posts/slug?key=value"
  ```
  """
  def url_for(resource_module, resource_id, params)
      when is_atom(resource_module) and is_list(params) do
    Resty.Resource.UrlBuilder.build(resource_module, resource_id, params)
  end
end
