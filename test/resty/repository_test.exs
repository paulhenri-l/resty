defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true
  alias Resty.Repository

  test "You can find a resource" do
    assert %Pipeline{id: 1} = Repository.find(Pipeline, 1)
  end

  test "You can create a resource" do
    pipeline = Pipeline.build(name: "test")
    saved_pipeline = Repository.save(pipeline)

    assert pipeline.name == saved_pipeline.name
    assert pipeline.name == Repository.find(Pipeline, saved_pipeline.id).name
  end
end
