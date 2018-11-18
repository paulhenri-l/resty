defmodule Fakes.EmptyResource do
  use Resty.Resource.Base
  @moduledoc false

  set_site("site.tld")
  set_resource_path("/empty")
  define_attributes([:name])
end
