defmodule Like do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/likes"
  define_attributes []
end
