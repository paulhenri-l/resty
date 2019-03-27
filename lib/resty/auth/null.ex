defmodule Resty.Auth.Null do
  @moduledoc """
  This is the default `Resty.Auth` implementation and it actually does not
  perform any kind of authentication.

  ## Usage

  As this is the default you should not have to manually set it except if you
  have changed the defaul auth in your config.exs file.

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    with_auth Resty.Auth.Null
  end
  ```
  """

  @doc false
  def authenticate(request, _), do: request
end
