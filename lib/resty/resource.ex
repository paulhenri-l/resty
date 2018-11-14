defmodule Resty.Resource do
  @moduledoc """
  This module provides a few functions to work with resource structs.
  """

  @doc """
  Clone the given resource
  """
  def clone(resource), do: clone(resource.__module__, resource)

  defp clone(module, resource) do
    resource
    |> Map.take(module.known_attributes())
    |> Map.delete(module.primary_key())
    |> module.build()
  end

  @doc """
  Is the given resource new? (not persisted)
  """
  def new?(resource), do: !persisted?(resource)

  @doc """
  Has the given resource been persisted?
  """
  def persisted?(%{__persisted__: persisted}), do: persisted

  @doc """
  Get the url to the given resource.
  **I will add examples**
  """
  def url_for(module) when is_atom(module) do
    url_for(module, [])
  end

  def url_for(resource) when is_map(resource) do
    module = resource.__struct__
    id = Map.get(resource, module.primary_key())
    url_for(module, id)
  end

  @doc """
  Get the url to the given resource.
  **I will add examples**
  """
  def url_for(resource, params) when is_map(resource) and is_list(params) do
    module = resource.__struct__
    id = Map.get(resource, module.primary_key())
    url_for(module, id, params)
  end

  def url_for(module, params) when is_atom(module) and is_list(params) do
    url_for(module, nil, params)
  end

  def url_for(module, id) when is_atom(module) do
    url_for(module, id, [])
  end

  @doc """
  Get the url to the given resource.
  **I will add examples**
  """
  def url_for(module, resource_id, params) when is_atom(module) and is_list(params) do
    Resty.Resource.UrlBuilder.build(module, resource_id, params)
  end
end
