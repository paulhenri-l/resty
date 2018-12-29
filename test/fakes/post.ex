defmodule Fakes.Post do
  use Resty.Resource.Base

  @moduledoc false

  set_site("site.tld")
  set_resource_path("/posts")
  add_header(:Custom, "hello")

  define_attributes([:name])

  # has_many(Fakes.Comment)
end
