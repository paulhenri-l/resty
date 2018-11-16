defmodule Resty.Auth do
  @moduledoc """
  Auth modules are used by Resty in order to authenticates request made to the
  web API.

  By default Resty will use `Resty.Auth.Null` but if you want to use another
  auth strategy you can use one of the existing one or write your own.

  You can specify which `Resty.Auth` implementation to  use on a per resource
  basis by calling the appropriate `Resty.Resource.Base` macro or globally
  by setting it in the config.
  """

  @doc false
  def authenticate(request, resource_module) do
    {implementation, params} = resource_module.auth()

    implementation.authenticate(request, params)
  end
end
