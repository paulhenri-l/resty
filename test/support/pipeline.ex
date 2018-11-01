defmodule Pipeline do
  use Resty.Resource

  site("localhost:3000")
  path("pipelines")

  field(:id, :int)
  field(:name, :string)
end
