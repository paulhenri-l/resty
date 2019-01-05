defmodule Author do
  use Resty.Resource.Base

  set_site("site.tld")
  set_resource_path("/authors")
  define_attributes([:name])
end
