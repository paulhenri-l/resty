defmodule Resty.Resource.Fields do
  # Fields might have to stay in the resource.

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :field_attributes, accumulate: true)
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
end
