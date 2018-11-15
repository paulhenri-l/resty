defmodule Resty.Resource.Base do
  @moduledoc """
  This module is used to create **resource struct** that you'll then be able to
  use with `Resty.Repo` and `Resty.Resource`.

  ## Using the module

  `Resty.Resource.Base` is here to help you create resource structs. The
  resource struct and its module holds informations about how to query the API
  such as the *site*, *headers*, *path*, *auth* etc...

  This module (`Resty.Resource.Base`) defines a lot of macros to configure
  these options. You'll be able to call them right after calling
  `use Resty.Resource.Base`.

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    set_site("site.tld")
    set_resource_path("/posts")

    define_attributes([:id, :name])
  end
  ```

  ### Attributes

  Unlike *ActiveResource* `Resty` will need you to define which attributes
  should be allowed on the resource.

  They are defined thanks to the `attribute/1` macro. The attributes does not
  support type casting, types are taken as they come from the json serializer.

  If you need to support more types than what json supports you can write your
  own `Resty.Serializer`.

  ## Using the resource

  Once you have a resource you can use it with `Resty.Repo` and `Resty.Resource`
  in order to query the API or get informations about retrieved resources.

  ```
  MyResource |> Resty.Repo.all!()
  ```
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import Resty.Resource.Base
      @before_compile unquote(__MODULE__)

      @default_headers Resty.default_headers()

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :headers, accumulate: true)
      Module.put_attribute(__MODULE__, :site, "")
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :primary_key, :id)
      Module.put_attribute(__MODULE__, :include_root, false)
      Module.put_attribute(__MODULE__, :extension, "")
      Module.put_attribute(__MODULE__, :connection, Resty.default_connection())
    end
  end

  @doc """
  Define the given attributes on the resource struct.

  *I'll add support for default values.*
  """
  defmacro define_attributes(attributes) when is_list(attributes) do
    quote do
      for new_attribute <- unquote(attributes) do
        Module.put_attribute(__MODULE__, :attributes, new_attribute)
      end
    end
  end

  @doc """
  Add a site to the resource
  """
  defmacro set_site(site) do
    quote(do: @site(unquote(site)))
  end

  @doc """
  Add a path to the resource
  """
  defmacro set_resource_path(path) do
    quote(do: @resource_path(unquote(path)))
  end

  @doc """
  Sets the resource primary key. By default it is `:id`.
  """
  defmacro set_primary_key(name) do
    quote(do: @primary_key(unquote(name)))
  end

  @doc """
  Sets the resource extension. The extension will be added in the URL.
  """
  defmacro set_extension(extension) do
    quote(do: @extension(unquote(extension)))
  end

  @doc """
  Include the given root when serializing the resource
  """
  defmacro include_root(value) do
    quote(do: @include_root(unquote(value)))
  end

  @doc """
  Add an header to the request sent from this resource
  """
  defmacro add_header(name, value) when is_atom(name) do
    quote(do: @headers({unquote(name), unquote(value)}))
  end

  defmacro __before_compile__(_env) do
    quote do
      defstruct @attributes ++
                  [
                    __module__: __MODULE__,
                    __persisted__: false
                  ]

      @doc false
      def site, do: @site

      @doc false
      def primary_key, do: @primary_key

      @doc false
      def resource_path, do: @resource_path

      @doc false
      def known_attributes, do: @attributes

      @doc false
      def serializer, do: Resty.Serializer.Json

      @doc false
      def include_root, do: @include_root

      @doc false
      def extension, do: @extension

      @doc false
      def headers, do: Keyword.merge(@default_headers, @headers)

      @doc false
      def connection, do: @connection

      @doc """
      Create a new resource with the given attributes
      """
      def build(attributes \\ []) do
        __MODULE__ |> struct(attributes)
      end
    end
  end
end
