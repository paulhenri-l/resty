defmodule Fakes.UuidResource do
  use Resty.Resource.Base

  @moduledoc false

  set_site("site.tld")
  set_resource_path("/posts")
  add_header(:Custom, "hello")
  set_primary_key(:uuid)
end
