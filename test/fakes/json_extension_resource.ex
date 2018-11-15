defmodule Fakes.JsonExtensionResource do
  @moduledoc false

  use Resty.Resource.Base

  set_site("site.tld")
  set_resource_path("/with-extension")
  set_extension(".json")

  define_attributes([:id])
end
