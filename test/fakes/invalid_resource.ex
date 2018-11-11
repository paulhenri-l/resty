defmodule Fakes.InvalidResource do
  use Resty.Resource

  set_site("site.tld")
  set_resource_path("invalid")

  field(:id)
end
