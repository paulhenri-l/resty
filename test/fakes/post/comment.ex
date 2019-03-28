defmodule Post.Comment do
  use Resty.Resource.Base

  set_site "site.tld"
  set_resource_path "/posts/:post_id/comments"
  define_attributes [:id, :body]

  belongs_to Post, :post, :post_id, false
end

