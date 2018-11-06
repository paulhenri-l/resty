defmodule Resty.Resource.Builder do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build, do: %__MODULE__{}

      def build(values) when is_map(values) do
        build() |> Map.merge(values)
      end

      def build(values) when is_list(values) do
        build(values, build())
      end

      def build([{field, value} | t], resource) do
        resource = Map.put(resource, field, value)
        build(t, resource)
      end

      def build([], resource), do: resource
    end
  end
end
