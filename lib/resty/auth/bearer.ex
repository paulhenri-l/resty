defmodule Resty.Auth.Bearer do
  @moduledoc """
  Authenticates by using a bearer token.

  ## Params

  The parameters are `:token`.

  ## Usage

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    with_auth(Resty.Auth.Beaer, token: "my-token")
  end
  ```
  """

  @doc false
  def authenticate(%{headers: headers} = request, params) do
    token = Keyword.get(params, :token, "default")

    updated_headers = Keyword.put(headers, :Authorization, "Bearer #{token}")

    %{request | headers: updated_headers}
  end
end
