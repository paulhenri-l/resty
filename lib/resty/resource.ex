defmodule Resty.Resource do
  # We may have to define a behaviour for the resource.
  # This behaviour will contain all of the used modules
  # callback definitions.

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :json_nesting_key, [])
      Module.put_attribute(__MODULE__, :json_nesting_key, nil)

      use Resty.Resource.Paths
      use Resty.Resource.Builder
      use Resty.Resource.Fields
    end
  end

  # @doc "Define the resource schema."
  # defmacro schema(path, do: fields), do: nil

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
    quote location: :keep do
      defstruct @fields ++ [__module__: __MODULE__]

      def from_json(json) when is_binary(json) do
        json = clean_json(json)

        case @json_nesting_key do
          nil -> Poison.decode!(json, as: build())
          {key, _} -> Poison.decode!(json, as: %{key => build()})[key]
          key -> Poison.decode!(json, as: %{key => build()})[key]
        end
      end

      def to_json(resource) do
        resource = Map.delete(resource, :__module__)

        case @json_nesting_key do
          nil -> Poison.encode!(resource)
          {_, key} -> Poison.encode!(%{key => resource})
          key -> Poison.encode!(%{key => resource})
        end
      end

      def clean_json(json) do
        data = Poison.decode!(json)

        cleanded_data =
          Enum.reduce(@fields, %{}, fn field, acc ->
            value = Map.get(data, to_string(field))

            case value do
              nil -> acc
              value -> Map.put(acc, field, value)
            end
          end)

        cleanded_data |> Poison.encode!()
      end
    end
  end
end
