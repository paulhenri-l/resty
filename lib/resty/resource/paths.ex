defmodule Resty.Resource.Paths do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.put_attribute(__MODULE__, :path, "")
      Module.put_attribute(__MODULE__, :site, "")
    end
  end

  @doc "Add a site to the resource"
  defmacro set_site(site) do
    quote do
      Module.put_attribute(__MODULE__, :site, unquote(site))
    end
  end

  @doc "Add a path to the resource"
  defmacro set_path(path) do
    quote do
      Module.put_attribute(__MODULE__, :path, unquote(path))
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def path, do: "#{@site}/#{@path}"
      def path(%__MODULE__{id: id}), do: path(id)
      def path(id), do: "#{path()}/#{id}"
    end
  end
end
