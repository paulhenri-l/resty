defmodule Resty.Serializer.Json do
  @moduledoc """
  This is the default `Resty.Serializer` implementation.

  Under the hood it uses `Jason` to decode/encode json.

  ## Params

  This serializer do not use any parameter.

  ## Usage

  As this is the default you should not have to manually set it except if you
  have changed the default serializer in your config.exs file.

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    set_serializer(Resty.Serializer.Json)
  end
  ```
  """

  @doc false
  def decode(json, _) do
    json
    |> do_decode()
    |> remove_root()
  end

  defp do_decode(json) do
    case Jason.decode(json) do
      {:error, error} -> raise error
      {:ok, result} -> result
    end
  end

  defp remove_root(list) when is_list(list), do: list

  defp remove_root(map), do: do_remove_root(map, Map.keys(map))

  defp do_remove_root(map, [key | []]) do
    case Map.get(map, key) do
      data when is_map(data) -> data
      data when is_list(data) -> data
      _ -> map
    end
  end

  defp do_remove_root(map, _), do: map

  @doc false
  def encode(map, params) do
    root = Keyword.get(params, :include_root, false)

    to_encode =
      case root do
        false -> map
        root -> Map.put(%{}, root, map)
      end

    to_encode |> Jason.encode!([])
  end
end
