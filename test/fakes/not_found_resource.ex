defmodule Fakes.NotFoundResource do
  use Resty.Resource

  set_site("site.tld")
  set_resource_path("not-found")

  attribute(:id)
end
