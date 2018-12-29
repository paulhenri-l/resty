defmodule Fakes.PostWithRelations do
  use Resty.Resource.Base

  @moduledoc false

  set_site("site.tld")
  set_resource_path("/posts-with-relations")

  define_attributes([:body])

  has_one(:author, Fakes.Author)
end
