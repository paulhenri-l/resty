defmodule Subscriber do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/subscribers"
  define_attributes []
end
