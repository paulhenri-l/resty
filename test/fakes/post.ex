defmodule Fakes.Post do
  use Resty.Resource

  set_site("localhost:3000")
  set_path("pipelines")
  set_json_nesting_key("data", "pipeline")

  field(:id, :int)
  field(:name, :string)
end
