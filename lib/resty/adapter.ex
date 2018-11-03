defmodule Resty.Adapter do
  @type path :: String.t()
  @type body :: String.t()
  @type headers :: keyword()
  @type response :: String.t()

  @callback get!(path, headers) :: response
  @callback head!(path, headers) :: response
  @callback post!(path, body, headers) :: response
  @callback patch!(path, body, headers) :: response
  @callback put!(path, body, headers) :: response
  @callback delete!(path, headers) :: response
end
