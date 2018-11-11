defmodule Fakes.Post do
  use Resty.Resource

  @moduledoc false

  set_site("site.tld")
  set_resource_path("posts")
  add_header(:Custom, "hello")

  attribute(:id)
  attribute(:name)
end
