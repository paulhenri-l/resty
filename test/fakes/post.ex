defmodule Fakes.Post do
  use Resty.Resource

  set_site("site.tld")
  set_path("posts")

  field(:id, :int)
  field(:name, :string)
end
