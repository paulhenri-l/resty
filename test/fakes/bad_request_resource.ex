defmodule Fakes.BadRequestResource do
  use Resty.Resource.Base
  @moduledoc false

  set_site("site.tld")
  set_resource_path("bad-request")

  attribute(:id)
end
