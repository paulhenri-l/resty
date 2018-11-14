defmodule Resty.Resource.UrlBuilderTest do
  use ExUnit.Case, async: true
  alias Fakes.PrefixedResource, as: Comment

  test "Building complicated urls" do
    params = [post_id: "some-post-id", key: "value"]
    expected_url = "site.tld/posts/some-post-id/comments/comment-id.json?key=value"

    assert Resty.Resource.UrlBuilder.build(Comment, "comment-id", params) == expected_url
  end
end
