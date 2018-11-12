defmodule Resty.Connection do
  @moduledoc """
  Connections are used by Resty in order to query the web API.

  By default Resty will use `Resty.Connections.HTTPoison` but if you want to
  use another HTTP client you'll have to write your own connection and adhere
  to this behaviour.

  Once that's done you'll be able to use it on a per resource basis by calling
  the appropriate `Resty.Resource.Base` macro or by setting it globally in the
  config.
  """

  @type t() :: module()
  @type serialized_response :: binary()
  @type response_ok :: {:ok, serialized_response}
  @type response_error :: {:error, Resty.Error.t()}

  @doc """
  Send the given request to the web API and return the response.
  """
  @callback send(request :: Resty.Request.t()) :: response_ok | response_error
end
