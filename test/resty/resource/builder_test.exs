defmodule Resty.Resource.BuilderTest do
  use ExUnit.Case, async: true
  alias Resty.Resource.Builder

  test "A resource can be built" do
    post1 = Builder.build(Post, %{name: "name-1", body: "body-1", __persisted__: true})
    post2 = Builder.build(Post, name: "name-2", body: "body-2", __persisted__: true)

    assert %Post{name: "name-1", body: "body-1", __persisted__: false} = post1
    assert %Post{name: "name-2", body: "body-2", __persisted__: false} = post2
  end

  test "A resource can be built with protected attributes" do
    post1 = Builder.build(Post, %{name: "name-1", body: "body-1", __persisted__: true}, false)
    post2 = Builder.build(Post, [name: "name-2", body: "body-2", __persisted__: true], false)

    assert %Post{name: "name-1", body: "body-1", __persisted__: true} = post1
    assert %Post{name: "name-2", body: "body-2", __persisted__: true} = post2
  end
end
