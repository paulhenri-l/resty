defmodule Fakes.InvalidResource do
  use Resty.Resource
  @moduledoc false

  set_site("site.tld")
  set_resource_path("invalid")

  attribute(:id)
end
