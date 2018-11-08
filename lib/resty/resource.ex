defmodule Resty.Resource do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      use Resty.Resource.Builder
      use Resty.Resource.Fields

      Module.put_attribute(__MODULE__, :site, "")
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :id_column, :id)

      Module.register_attribute(__MODULE__, :json_nesting_key, [])
      Module.put_attribute(__MODULE__, :json_nesting_key, nil)
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
  defmacro set_id_column(name) do
    quote(do: @id_column(unquote(name)))
  end

  @doc "Add a json nesting key to the resource"
  defmacro set_json_nesting_key(key) do
    quote do
      Module.put_attribute(__MODULE__, :json_nesting_key, unquote(key))
    end
  end

  defmacro set_json_nesting_key(read_key, write_key) do
    quote do
      Module.put_attribute(__MODULE__, :json_nesting_key, {unquote(read_key), unquote(write_key)})
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @derive {Jason.Encoder, only: @fields}
      defstruct @fields ++ [__module__: __MODULE__]

      def site, do: @site
      def id_column, do: @id_column
      def resource_path, do: @resource_path
      def fields, do: @fields
    end
  end
end
