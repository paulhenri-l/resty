defmodule Resty.Resource.UrlBuilder do
  @moduledoc false

  def build(module, id, params) do
    {final_url, _} =
      {module.site(), params}
      |> add_resource_path(module.resource_path(), id)
      |> replace_prefix_params()
      |> add_extension(module.extension())
      |> add_query_string()

    final_url
  end

  defp add_resource_path({url, params}, resource_path, nil) do
    {url <> resource_path, params}
  end

  defp add_resource_path({url, params}, resource_path, id) do
    {url <> resource_path <> "/#{id}", params}
  end

  defp add_extension({url, params}, extension) do
    {url <> extension, params}
  end

  defp replace_prefix_params(url_data, unused_params \\ [])
  defp replace_prefix_params({url, []}, unused_params), do: {url, unused_params}

  defp replace_prefix_params({url, [{param, value} | next_params]}, unused_params) do
    case String.contains?(url, ":#{param}") do
      false ->
        replace_prefix_params({url, next_params}, unused_params ++ [{param, value}])

      true ->
        value = value |> to_string() |> URI.encode_www_form()
        updated_url = String.replace(url, ":#{param}", value)
        replace_prefix_params({updated_url, next_params}, unused_params)
    end
  end

  defp add_query_string({_, []} = url_data), do: url_data

  defp add_query_string({url, params}) do
    {url <> "?" <> URI.encode_query(params), []}
  end
end
