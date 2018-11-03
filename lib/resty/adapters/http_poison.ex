defmodule Resty.Adapters.HTTPoison do
  @behaviour Resty.Adapter

  def get!(path, headers), do: HTTPoison.get!(path, headers).body
  def head!(path, headers), do: HTTPoison.head!(path, headers).body
  def post!(path, body, headers), do: HTTPoison.post!(path, body, headers).body
  def patch!(path, body, headers), do: HTTPoison.patch!(path, body, headers).body
  def put!(path, body, headers), do: HTTPoison.put!(path, body, headers).body
  def delete!(path, headers), do: HTTPoison.delete!(path, headers).body
end
