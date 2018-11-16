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
    user = Keyword.get(params, :user, "default") |> URI.encode_www_form()
    password = Keyword.get(params, :password, "default") |> URI.encode_www_form()

    user <> ":" <> password
  end
end
