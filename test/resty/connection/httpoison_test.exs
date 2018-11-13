defmodule Resty.Connection.HTTPoisonTest do
  use ExUnit.Case, async: true
  alias Resty.Error
  alias Resty.Request
  alias Resty.Connection.HTTPoison, as: Connection

  @test_address "https://httparrot.herokuapp.com"

  @tag :external
  test "It returns the response body" do
    {:ok, body} =
      get_request("/headers", %{"x-test" => "hello-from-test"})
      |> Connection.send()

    assert body |> String.contains?(~s("x-test": "hello-from-test"))
  end

  @tag :external
  test "It handles connections errors" do
    assert {:error, _} = Request.new(url: "not-a-url") |> Connection.send()
  end

  @tag :external
  test "It treats redirects as errors" do
    for code <- [301, 302, 303, 307] do
      assert {:error, %Error.Redirection{code: code}} =
               get_request("/status/#{code}")
               |> Connection.send()
    end
  end

  @tag :external
  test "It handles 400" do
    assert {:error, %Error.BadRequest{}} =
             get_request("/status/400")
             |> Connection.send()
  end

  @tag :external
  test "It handles 401" do
    assert {:error, %Error.UnauthorizedAccess{}} =
             get_request("/status/401")
             |> Connection.send()
  end

  @tag :external
  test "It handles 403" do
    assert {:error, %Error.ForbiddenAccess{}} =
             get_request("/status/403")
             |> Connection.send()
  end

  @tag :external
  test "It handles 404" do
    assert {:error, %Error.ResourceNotFound{}} =
             get_request("/status/404")
             |> Connection.send()
  end

  @tag :external
  test "It handles 405" do
    assert {:error, %Error.MethodNotAllowed{}} =
             get_request("/status/405")
             |> Connection.send()
  end

  @tag :external
  test "It handles 409" do
    assert {:error, %Error.ResourceConflict{}} =
             get_request("/status/409")
             |> Connection.send()
  end

  @tag :external
  test "It handles 410" do
    assert {:error, %Error.ResourceGone{}} =
             get_request("/status/410")
             |> Connection.send()
  end

  @tag :external
  test "It handles 422" do
    assert {:error, %Error.ResourceInvalid{}} =
             get_request("/status/422")
             |> Connection.send()
  end

  @tag :external
  test "It handles other 4xx codes" do
    assert {:error, %Error.ClientError{code: 418}} =
             get_request("/status/418")
             |> Connection.send()
  end

  @tag :external
  test "It handles other 5xx codes" do
    assert {:error, %Error.ServerError{}} =
             get_request("/status/500")
             |> Connection.send()
  end

  defp get_request(path, headers \\ []) do
    Request.new(method: :get, url: @test_address <> path, headers: headers)
  end
end
