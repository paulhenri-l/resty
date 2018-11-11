defmodule Resty.Resource do
  @moduledoc """
  This module is used to create **resources** that you'll then be able to
  use with `Resty.Repo` in order to query a web API.
  """

  @typedoc "A resource struct."
  @type t :: struct()

  @typedoc "A resource module (the one that defines the struct)."
  @type resource_module :: module()

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

  @doc "Clone the given resource"
  @spec clone(t()) :: t()
  def clone(resource), do: clone(resource.__module__, resource)

  @spec clone(resource_module(), t()) :: t()
  defp clone(module, resource) do
    resource
    |> Map.take(module.known_attributes())
    |> Map.delete(module.primary_key())
    |> module.build()
  end

  @doc "Add an attribute to the resource"
  @spec attribute(atom()) :: none()
  defmacro attribute(name) do
    quote do
      Module.put_attribute(__MODULE__, :attributes, unquote(name))
    end
  end

  @doc "Add a site to the resource"
  @spec set_site(String.t()) :: none()
  defmacro set_site(site) do
    quote(do: @site(unquote(site)))
  end

  @doc "Add a path to the resource"
  @spec set_resource_path(String.t()) :: none()
  defmacro set_resource_path(path) do
    quote(do: @resource_path(unquote(path)))
  end

  @doc """
  Sets the resource primary key. By default it is `:id`.

  ## Usage
    iex> defmodule Post do
    ...> use Resty.Resource
    ...> set_primary_key(:uuid)
    ...> end
    ...>
    ...> Post.primary_key()
    :uuid

  """
  @spec set_primary_key(atom()) :: none()
  defmacro set_primary_key(name) do
    quote(do: @primary_key(unquote(name)))
  end

  @doc "Include the given root when serializing the resource"
  @spec include_root(false | String.t()) :: none()
  defmacro include_root(value) do
    quote(do: @include_root(unquote(value)))
  end

  @doc "Add an header to the request sent from this resource"
  @spec add_header(atom(), String.t()) :: none()
  defmacro add_header(name, value) when is_atom(name) do
    quote(do: @headers({unquote(name), unquote(value)}))
  end

  defmacro __before_compile__(_env) do
    quote do
      defstruct @attributes ++ [__module__: __MODULE__]

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
      def headers, do: Keyword.merge(@default_headers, @headers)

      @doc "Create a new resource with the given attributes"
      @spec build(Enum.t()) :: Resty.Resource.t()
      def build(attributes \\ []), do: __MODULE__ |> struct(attributes)
    end
  end
end
