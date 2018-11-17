defmodule RestyTest do
  use ExUnit.Case

  @default_headers [
    "Content-Type": "application/json",
    Accept: "application/json; Charset=utf-8"
  ]

  test "default headers" do
    assert @default_headers == Resty.default_headers()
  end

  test "default connection" do
    assert Fakes.TestConnection == Resty.default_connection()
  end

  test "default serializer" do
    assert Resty.Serializer.Json == Resty.default_serializer()
  end

  test "default auth" do
    assert Resty.Auth.Null == Resty.default_auth()
  end

  test "default site" do
    assert nil == Resty.default_site()
  end
end
