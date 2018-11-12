defmodule Resty do
  @moduledoc """
  This module does not do much.
  It is used in order to retrieve default values from the config.
  """

  @doc """
  Return the default headers that are going to be sent for every resource.
  """
  @spec default_headers() :: keyword()
  def default_headers do
    Application.get_env(:resty, :default_headers,
      "Content-Type": "application/json",
      Accept: "application/json; Charset=utf-8"
    )
  end

  @doc """
  Return the default connection that will be used for every resource.
  """
  @spec default_connection() :: Resty.Connection.t()
  def default_connection do
    Application.get_env(:resty, :connection, Resty.Connections.HTTPoison)
  end
end
