defmodule Resty.Auth.BasicTest do
  use ExUnit.Case, async: true
  alias Resty.Request
  alias Resty.Auth.Basic

  test "Authenticates https request" do
    request = %Request{url: "https://site.tld/posts/1"}

    authenicated_request = Basic.authenticate(request, user: "user", password: "1234")

    assert "https://user:1234@site.tld/posts/1" == authenicated_request.url
  end

  test "Authenticates http request" do
    request = %Request{url: "http://site.tld/posts/1"}

    authenicated_request = Basic.authenticate(request, user: "user", password: "1234")

    assert "http://user:1234@site.tld/posts/1" == authenicated_request.url
  end

  test "Authenticates schemaless request" do
    request = %Request{url: "site.tld/posts/1"}

    authenicated_request = Basic.authenticate(request, user: "user", password: "1234")

    assert "user:1234@site.tld/posts/1" == authenicated_request.url
  end

  test "Authenticates encodes username and password" do
    request = %Request{url: "https://site.tld/posts/1"}

    authenicated_request = Basic.authenticate(request, user: "u$er", password: "pa$$word")

    assert "https://u%24er:pa%24%24word@site.tld/posts/1" == authenicated_request.url
  end

  test "User and password can be set from config" do
    request = %Request{url: "https://site.tld/posts/1"}

    authenicated_request = Basic.authenticate(request, [])

    assert "https://conf-user:conf-password@site.tld/posts/1" == authenicated_request.url
  end
end
