defmodule Resty do
  @moduledoc """
  This module does not do much.
  It is used in order to retrieve values from the config.

  *I will explain what are these values and how to set them before 1.0*
  """

  @doc """
  Return the default headers that are going to be sent for every resource.
  """
  def default_headers do
    Application.get_env(:resty, :default_headers,
      "Content-Type": "application/json",
      Accept: "application/json; Charset=utf-8"
    )
  end

  @doc """
  Return the default connection that will be used for every resource.
  """
  def default_connection do
    Application.get_env(:resty, :connection, Resty.Connection.HTTPoison)
  end
end
