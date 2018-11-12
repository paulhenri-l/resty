defmodule Resty.Request do
  @moduledoc """
  This module defines the struct that `Resty.Repo` will send to the configured
  `Resty.Connection` implementation whenever it will want to query the web API.
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
