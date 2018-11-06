defmodule Resty.Resource do
  # We may have to define a behaviour for the resource.
  # This behaviour will contain all of the used modules
  # callback definitions.

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      use Resty.Resource.Paths
      use Resty.Resource.Builder
      use Resty.Resource.Fields
      use Resty.Resource.Serializer
    end
  end

  # @doc "Define the resource schema."
  # defmacro schema(path, do: fields), do: nil

  defmacro __before_compile__(_env) do
    quote do
      defstruct @fields ++ [__module__: __MODULE__]
    end
  end
end
