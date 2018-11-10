defmodule Resty.Serializer.JsonTest do
  use ExUnit.Case, async: true
  alias Resty.Serializer.Json

  test "The root can be removed" do
    json_post = %{"post" => %{"id" => 1}} |> Jason.encode!()
    json_data = %{"data" => %{"id" => 1}} |> Jason.encode!()

    assert %{id: 1} == Json.decode(json_post, [:id])
    assert %{id: 1} == Json.decode(json_data, [:id])
  end
end
