defmodule Resty.Resource do
  @moduledoc """
  This module provides a few functions to work on resources.
  """

  @typedoc "A resource module"
  @type resource_module() :: module()

  @typedoc "A resource struct."
  @type t() :: %{
          __module__: resource_module(),
        }

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
end
