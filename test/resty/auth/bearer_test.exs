defmodule Resty.Auth.BearerTest do
  use ExUnit.Case, async: true
  alias Resty.Request
  alias Resty.Auth.Bearer

  test "The bearer token is added to the request" do
    request = %Request{}

    authenicated_request = Bearer.authenticate(request, token: "my-token")

    assert [Authorization: "Bearer my-token"] == authenicated_request.headers
  end
end
