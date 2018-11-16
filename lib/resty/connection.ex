defmodule Resty.Connection do
  @moduledoc """
  Connection are used by Resty in order to query the web API.

  By default Resty will use `Resty.Connection.HTTPoison` but if you want to
  use another HTTP client you'll have to write your own connection
  implementation.

  Once that's done you'll be able to use it on a per resource basis by calling
  the appropriate `Resty.Resource.Base` macro or globally by setting it in the
  config.
  """

  @doc false
  def send(request, resource_module) do
    request |> resource_module.connection().send()
  end
end
