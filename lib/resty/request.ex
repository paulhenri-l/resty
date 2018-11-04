defmodule Resty.Request do

  @type t :: %__MODULE__{}

  defstruct method: :get, url: "", headers: [], body: ""
end
