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

  @doc "Get the path to the given resource."
  def path_to(module) when is_atom(module) do
    Resty.Resource.UrlBuilder.build(module, nil, [])
  end

  def path_to(%{} = resource) do
    path_to(resource.__module__, resource)
  end

  @doc "Get the path to the given resource."
  def path_to(module, %{} = resource) do
    id = Map.get(resource, module.primary_key())

    Resty.Resource.UrlBuilder.build(module, id, [])
  end

  def path_to(module, id) do
    Resty.Resource.UrlBuilder.build(module, id, [])
  end
end
