defmodule Resty.Resource do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      use Resty.Resource.Builder
      use Resty.Resource.Fields
      use Resty.Resource.Serializer

      Module.put_attribute(__MODULE__, :site, "")
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :id_column, :id)

      Module.register_attribute(__MODULE__, :meta, accumulate: true)
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

  defmacro __before_compile__(_env) do
    quote do
      defstruct @fields ++ [__module__: __MODULE__]

      def meta, do: @meta
      def site, do: @site
      def id_column, do: @id_column
      def resource_path, do: @resource_path

      def path, do: __MODULE__ |> Resty.Resource.Path.to()
      def path(id_or_resource), do: __MODULE__ |> Resty.Resource.Path.to(id_or_resource)
    end
  end
end
