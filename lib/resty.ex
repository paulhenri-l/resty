defmodule Resty do
  @moduledoc """
  This module makes it easy for Resty's modules to get default configuration
  values.

  All of these values can be changed in your config.exs file in order to
  globally change the way Resty works.
  """

  @doc """
  Return the *global headers* that are going to be sent for every resource.

  The defaults are:

  ```
  [
    "Content-Type": "application/json",
    Accept: "application/json; Charset=utf-8"
  ]
  ```

  This value can be configured in your config.exs file like this:

  ```
  config :resty, headers: [
    "Content-Type": "application/json",
    Accept: "application/json; Charset=utf-8"
  ]
  ```

  You can also set it on a per resource basis thanks to the
  `Resty.Resource.Base.set_headers/1` macro.
  """
  def default_headers do
    Application.get_env(:resty, :headers,
      "Content-Type": "application/json",
      Accept: "application/json; Charset=utf-8"
    )
  end

  @doc """
  Return the global `Resty.Connection` that will be used to query every
  resource.

  This value can be configured in your config.exs file like this:

  ```
  config :resty, connection: Resty.Connection.HTTPoison
  ```

  You can also set it on a per resource basis thanks to the
  `Resty.Resource.Base.set_connection/1` macro.
  """
  def default_connection do
    Application.get_env(:resty, :connection, Resty.Connection.HTTPoison)
  end

  @doc """
  Return the `Resty.Auth` implementation that should be used to authenticate
  outgoing requests.

  The default is `Resty.Auth.Null`

  This value can be configured in your config.exs file like this:

  ```
  config :resty, auth: Resty.Auth.Null
  ```

  You can also set it on a per resource basis thanks to the
  `Resty.Resource.Base.with_auth/2` macro.
  """
  def default_auth do
    Application.get_env(:resty, :auth, Resty.Auth.Null)
  end

  @doc false
  def global_serializer, do: Resty.Serializer.Json
end
