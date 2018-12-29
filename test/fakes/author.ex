defmodule Fakes.Author do
  use Resty.Resource.Base

  @moduledoc false

  set_site("site.tld")
  set_resource_path("/authors")

  define_attributes([:name])

  # has_many(:posrs, Fakes.Post)
end
