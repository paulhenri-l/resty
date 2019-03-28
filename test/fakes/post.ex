defmodule Post do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/posts"
  add_header :Custom, "hello"

  define_attributes [:name, :body]

  belongs_to Author, :author, :author_id
  has_many Post.Comment, :comments, :post_id
end
