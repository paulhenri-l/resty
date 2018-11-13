defmodule Resty.Request do
  @moduledoc """
  This module defines the struct that `Resty.Repo` will send to the configured
  `Resty.Connection` implementation whenever it will want to query the web API.
  """

  defstruct method: :get, url: "", headers: [], body: ""

  @type t :: %__MODULE__{}

  @doc "Create a new empty request."
  def new, do: %__MODULE__{}

  @doc "Create a new request with the given options."
  def new(options) do
    new() |> struct(options)
  end
end
