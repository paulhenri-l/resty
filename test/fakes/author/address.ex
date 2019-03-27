defmodule Author.Address do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/authors/:author_id/address"
  define_attributes [:author_id, :city]

  belongs_to Author, :author, :author_id, false
end
