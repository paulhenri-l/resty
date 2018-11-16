defmodule Resty.Auth do
  @moduledoc "Doc about auth"

  @doc false
  def authenticate(request, resource_module) do
    {implementation, params} = resource_module.auth()

    implementation.authenticate(request, params)
  end
end
