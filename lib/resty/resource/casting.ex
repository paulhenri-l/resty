defmodule Resty.Resource.Casting do
  def cast(resource, _field_attributes) do
    resource
  end

  def create_type_casters(fields) do
    create_type_casters(fields, [])
  end

  def create_type_casters([], casters), do: casters

  def create_type_casters([{field, %{type: type}} | t], casters) do
    casters = casters ++ [create_caster(field, type)]

    create_type_casters(t, casters)
  end

  def create_type_casters([_ | t], casters), do: create_type_casters(t, casters)

  def create_caster(field, :int) do
    quote do
      def cast(resource = %__MODULE__{})
      def cast(unquote(field), value) when is_integer(value), do: value
      def cast(unquote(field), value), do: String.to_integer(value)
    end
  end

  def create_caster(field, :string) do
    quote do
      def cast(unquote(field), value) when is_binary(value), do: value
      def cast(unquote(field), value), do: to_string(value)
    end
  end
end
