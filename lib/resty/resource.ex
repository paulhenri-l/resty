defmodule Resty.Resource do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      @default_headers Application.get_env(:resty, :default_headers,
                         "Content-Type": "application/json",
                         Accept: "application/json; Charset=utf-8"
                       )

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :headers, accumulate: true)
      Module.put_attribute(__MODULE__, :site, "")
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :primary_key, :id)
      Module.put_attribute(__MODULE__, :include_root, false)
    end
  end

  @doc "Add an attribute to the resource"
  defmacro attribute(name) do
    quote do
      Module.put_attribute(__MODULE__, :attributes, unquote(name))
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

  @doc "Add an header to the request sent from this resource"
  defmacro add_header(name, value) when is_atom(name) do
    quote(do: @headers({unquote(name), unquote(value)}))
  end

  defmacro __before_compile__(_env) do
    quote do
      defstruct @attributes ++ [__module__: __MODULE__]

      def site, do: @site
      def primary_key, do: @primary_key
      def resource_path, do: @resource_path
      def known_attributes, do: @attributes
      def serializer, do: Resty.Serializer.Json
      def include_root, do: @include_root
      def headers, do: Keyword.merge(@default_headers, @headers)

      def build(values \\ []), do: __MODULE__ |> struct(values)
    end
  end
end
