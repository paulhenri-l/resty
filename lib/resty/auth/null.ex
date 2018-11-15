defmodule Resty.Auth.Null do
  def authenticate(request, _), do: request
end
