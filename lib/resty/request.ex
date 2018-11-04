defmodule Resty.Request do
  @type t :: %__MODULE__{}

  defstruct method: :get, url: "", headers: [], body: ""

  def new, do: %__MODULE__{}

  def new(options) do
    new() |> struct(options)
  end
end
