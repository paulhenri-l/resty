defmodule Resty.Request do
  @moduledoc """
  If you are fine with `Resty` using `HTTPoison` as its http client then you do
  not need to worry about this module.

  But if you feel the need to use another client you'll have to create a new
  `Resty.Connection` module.

  This module defines the struct that `Resty.Repo` will send to your newly
  created `Resty.Connection` module whenever it will want to query the web API.
  """

  @type t :: %__MODULE__{
          method: atom(),
          url: String.t(),
          headers: Keyword.t(String.t()),
          body: String.t()
        }

  defstruct method: :get,
            url: "",
            headers: [],
            body: ""

  @doc "Create a new empty request."
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc "Create a new request with the given options."
  @spec new(Enum.t()) :: t()
  def new(options) do
    new() |> struct(options)
  end
end
