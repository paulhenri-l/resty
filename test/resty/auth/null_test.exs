defmodule Resty.Auth.NullTest do
  use ExUnit.Case, async: true
  alias Resty.Request
  alias Resty.Auth.Null

  test "that nothing has changed" do
    request = %Request{url: "https://site.tld/posts/1"}

    authenicated_request = Null.authenticate(request, user: "user", password: "1234")

    assert request == authenicated_request
  end
end
