defmodule Resty.Resource.Builder do
  @moduledoc false

  def build(module, attributes) do
    module |> struct(attributes)
  end
end
