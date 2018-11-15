defmodule Fakes.NotFoundResource do
  use Resty.Resource.Base
  @moduledoc false

  set_site("site.tld")
  set_resource_path("/not-found")

  attributes([:id])
end
