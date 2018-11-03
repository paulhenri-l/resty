defmodule Fakes.Post do
  use Resty.Resource

  set_site("site.tld")
  set_path("posts")
  # set_json_nesting_key("data", "post")

  field(:id, :int)
  field(:name, :string)
end
