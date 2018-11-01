defmodule Resty.Resource do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :field_attributes, accumulate: true)
    end
  end

  # @doc "Define the resource schema."
  # defmacro schema(path, do: fields), do: nil

  @doc "Add a site to the resource"
  defmacro site(site) do
    quote do
      Module.put_attribute(__MODULE__, :site, unquote(site))
    end
  end

  @doc "Add a path to the resource"
  defmacro path(path) do
    quote do
      Module.put_attribute(__MODULE__, :path, unquote(path))
    end
  end

  @doc "Add a field to the resource"
  defmacro field(name) do
    quote do
      field(unquote(name), :string)
    end
  end

  defmacro field(name, type) do
    quote do
      field_attributes =
        Map.new()
        |> Map.put(:type, unquote(type))

      Module.put_attribute(__MODULE__, :fields, unquote(name))
      Module.put_attribute(__MODULE__, :field_attributes, {unquote(name), field_attributes})
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defstruct @fields

      def path, do: @path
      def site, do: @site
      def build, do: %__MODULE__{}

      def build(values) when is_map(values) do
        build() |> Map.merge(values)
      end

      def build(values) when is_binary(values) do
        Poison.decode!(values, as: build())
      end
    end
  end
end
