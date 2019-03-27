defmodule Comment do
  use Resty.Resource.Base

  set_site "site.tld/posts/:post_id"
  set_resource_path "/comments"
  set_extension ".json"

  define_attributes [:name]
end
