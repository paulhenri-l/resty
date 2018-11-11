defmodule Fakes.BadRequestResource do
  use Resty.Resource

  set_site("site.tld")
  set_resource_path("bad-request")

  field(:id)
end
