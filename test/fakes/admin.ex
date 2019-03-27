defmodule Admin do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/admins"
  define_attributes []
  set_primary_key :uuid
  set_extension ".json"
end
