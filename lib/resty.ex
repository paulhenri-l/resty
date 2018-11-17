defmodule Resty do
  @moduledoc """
  This module makes it easy for Resty's modules to get default configuration
  values.

  All of these values can be changed in your config.exs file in order to
  globally change the way Resty works.
  """

  @doc """
  Return the *default headers* that are going to be sent for every resource.

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

  @doc """
  Return the `Resty.Serializer` implementation that should be used to serialize
  and deserialize resources.

  The default is `Resty.Serializer.Json`

  This value can be configured in your config.exs file like this:

  ```
  config :resty, serializer: Resty.Serializer.Json
  ```

  You can also set it on a per resource basis thanks to the
  `Resty.Resource.Base.set_serializer/2` macro.
  """
  def default_serializer do
    Application.get_env(:resty, :serialize, Resty.Serializer.Json)
  end

  @doc """
  Return the default site that is going to be queried for every resource.

  The default is `nil`.

  This value can be configured in your config.exs file like this:

  ```
  config :resty, site: "https://my-webservice.com/api/v2"
  ```

  You can also set it on a per resource basis thanks to the
  `Resty.Resource.Base.set_site/1` macro.
  """
  def default_site do
    Application.get_env(:resty, :site, nil)
  end
end
