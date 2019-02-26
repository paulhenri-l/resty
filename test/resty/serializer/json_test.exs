defmodule Resty.Serializer.JsonTest do
  use ExUnit.Case, async: true
  alias Resty.Serializer.Json

  test "The root can be removed" do
    json_post = %{"post" => %{"id" => 1}} |> Jason.encode!()
    json_data = %{"data" => %{"id" => 1}} |> Jason.encode!()

    assert %{"id" => 1} == Json.decode(json_post, [])
    assert %{"id" => 1} == Json.decode(json_data, [])
  end

  test "When there is no root it also works" do
    json = %{"id" => 1} |> Jason.encode!()

    assert %{"id" => 1} == Json.decode(json, [])
  end

  test "Data can be encoded" do
    result = %{id: 1} |> Json.encode([])

    assert ~s({"id":1}) = result
  end

  test "Data can be encoded with a root" do
    result_data = %{id: 1} |> Json.encode(include_root: "data")
    result_post = %{id: 1} |> Json.encode(include_root: "post")

    assert ~s({"data":{"id":1}}) = result_data
    assert ~s({"post":{"id":1}}) = result_post
  end
end
