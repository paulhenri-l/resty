defmodule Fakes.PrefixedResource do
  use Resty.Resource.Base

  @moduledoc false

  set_site("site.tld/posts/:post_id")
  set_resource_path("/comments")
  set_extension(".json")

  attributes([:id, :name])
end
