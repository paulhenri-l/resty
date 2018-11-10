defmodule Resty.Serializer.JsonTest do
  use ExUnit.Case, async: true
  alias Resty.Serializer.Json

  test "The root can be removed" do
    json_post = %{"post" => %{"id" => 1}} |> Jason.encode!()
    json_data = %{"data" => %{"id" => 1}} |> Jason.encode!()

    assert %{id: 1} == Json.decode(json_post, [:id])
    assert %{id: 1} == Json.decode(json_data, [:id])
  end

  test "When there is no root it also works" do
    json = %{"id" => 1} |> Jason.encode!()

    assert %{id: 1} == Json.decode(json, [:id])
  end

  test "Data can be encoded" do
    result = %{id: 1, nope: "nope"} |> Json.encode([:id])

    assert ~s({"id":1}) = result
  end

  test "Data can be encoded with a root" do
    result_data = %{id: 1} |> Json.encode([:id], "data")
    result_post = %{id: 1} |> Json.encode([:id], "post")

    assert ~s({"data":{"id":1}}) = result_data
    assert ~s({"post":{"id":1}}) = result_post
  end
end
