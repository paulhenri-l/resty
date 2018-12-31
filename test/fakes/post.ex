defmodule Post do
  use Resty.Resource.Base

  set_site("site.tld")
  set_resource_path("/posts")
  add_header(:Custom, "hello")

  define_attributes([:name, :body])
end
