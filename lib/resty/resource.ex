defmodule Resty.Resource do
  @moduledoc """
  This module provides a few functions to work with resource structs.
  """

  @typedoc "A resource module"
  @type resource_module() :: module()

  @typedoc "A resource struct."
  @type t() :: %{
          __module__: resource_module(),
          __persisted__: boolean()
        }

  @typedoc "A collection of resource structs"
  @type collection() :: [t()]

  @doc """
  Clone the given resource
  """
  @spec clone(t()) :: t()
  def clone(resource), do: clone(resource.__module__, resource)

  @spec clone(resource_module(), t()) :: t()
  defp clone(module, resource) do
    resource
    |> Map.take(module.known_attributes())
    |> Map.delete(module.primary_key())
    |> module.build()
  end

  @doc """
  Is the given resource new? (not persisted)
  """
  @spec new?(t()) :: boolean()
  def new?(resource), do: !persisted?(resource)

  @doc """
  Has the given resource been persisted?
  """
  @spec persisted?(t()) :: boolean()
  def persisted?(%{__persisted__: persisted}), do: persisted
end
