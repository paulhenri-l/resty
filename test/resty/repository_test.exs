defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true

  test "You can find a resource" do
    pipeline = Resty.Repository.find(Pipeline, 1)

    assert :ok == pipeline
  end
end
