defmodule Resty.Auth.Basic do
  @moduledoc """
  Authenticates by using basic auth.

  ## Params

  The parameters are `:user`, `:password`.

  ## Usage

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    with_auth(Resty.Auth.Basic, user: "hello", password: "hola")
  end
  ```

  You can also define a default user and password in your config.exs file

  ```
  config :resty, Resty.Auth.Basic, user: "user", password: "password"
  ```

  Thus making it possible to use `Resty.Resource.Base.with_auth/1`

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    with_auth(Resty.Auth.Basic)
  end
  ```
  """

  @doc false
  def authenticate(%{url: "https://" <> rest_of_url} = request, auth_params) do
    new_url = "https://" <> do_authenticate(rest_of_url, auth_params)

    %{request | url: new_url}
  end

  def authenticate(%{url: "http://" <> rest_of_url} = request, auth_params) do
    new_url = "http://" <> do_authenticate(rest_of_url, auth_params)

    %{request | url: new_url}
  end

  def authenticate(%{url: rest_of_url} = request, auth_params) do
    new_url = do_authenticate(rest_of_url, auth_params)

    %{request | url: new_url}
  end

  defp do_authenticate(url, params) do
    basic_auth_string(params) <> "@" <> url
  end

  defp basic_auth_string(params) do
    user = Keyword.get(params, :user, default_user()) |> URI.encode_www_form()
    password = Keyword.get(params, :password, default_password()) |> URI.encode_www_form()

    user <> ":" <> password
  end

  defp default_user do
    Application.get_env(:resty, __MODULE__) |> Keyword.get(:user)
  end

  defp default_password do
    Application.get_env(:resty, __MODULE__) |> Keyword.get(:password)
  end
end
