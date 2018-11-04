defmodule Resty.Connection do
  @type json :: String.t()

  @type response_ok :: {:ok, json}
  @type response_error :: {:error, Resty.Error.t()}

  @callback send(Resty.Request.t()) :: response_ok | response_error
end
