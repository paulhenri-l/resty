defmodule RestyTest do
  use ExUnit.Case
  doctest Resty

  test "greets the world" do
    assert Resty.hello() == :world
  end
end
