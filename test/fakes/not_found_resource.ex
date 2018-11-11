defmodule Fakes.NotFoundResource do
  use Resty.Resource
  @moduledoc false

  set_site("site.tld")
  set_resource_path("not-found")

  attribute(:id)
end
