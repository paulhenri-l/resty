# Remove root -> when decoding
# Include root in json
# resource name -> infer from module
# These are serializer options

defmodule Resty.Resource do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.put_attribute(__MODULE__, :site, "")
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :primary_key, :id)
      Module.put_attribute(__MODULE__, :include_root, false)
    end
  end

  @doc "Add a field to the resource"
  defmacro field(name) do
    quote do
      Module.put_attribute(__MODULE__, :fields, unquote(name))
    end
  end

  @doc "Add a site to the resource"
  defmacro set_site(site) do
    quote(do: @site(unquote(site)))
  end

  @doc "Add a path to the resource"
  defmacro set_resource_path(path) do
    quote(do: @resource_path(unquote(path)))
  end

  @doc "Set id column"
  defmacro set_primary_key(name) do
    quote(do: @primary_key(unquote(name)))
  end

  @doc "Include the given root when serializing the resource"
  defmacro include_root(value) do
    quote(do: @include_root(unquote(value)))
  end

  defmacro __before_compile__(_env) do
    quote do
      @derive {Jason.Encoder, only: @fields}
      defstruct @fields ++ [__module__: __MODULE__]

      def site, do: @site
      def primary_key, do: @primary_key
      def resource_path, do: @resource_path
      def fields, do: @fields
      def serializer, do: Resty.Serializer.Json
      def include_root, do: @include_root

      def build(values \\ []), do: __MODULE__ |> struct(values)
    end
  end
end
