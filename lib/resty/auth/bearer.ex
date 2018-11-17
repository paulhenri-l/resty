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

  You can also define a default token in your config.exs file

  ```
  config :resty, Resty.Auth.Bearer, token: "my-token-from-config"
  ```

  Thus making it possible to use `Resty.Resource.Base.with_auth/1`

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    with_auth(Resty.Auth.Beaer)
  end
  ```
  """

  @doc false
  def authenticate(%{headers: headers} = request, params) do
    token = Keyword.get(params, :token, default())

    updated_headers = Keyword.put(headers, :Authorization, "Bearer #{token}")

    %{request | headers: updated_headers}
  end

  @doc false
  def default do
    Application.get_env(:resty, __MODULE__) |> Keyword.get(:token, "")
  end
end
