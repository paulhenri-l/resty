defmodule Resty.RepositoryTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Error
  alias Resty.Repository

  test "find :ok" do
    assert {:ok, %Post{id: 1}} = Repository.find(Post, 1)
  end

  test "find :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repository.find(Post, "not-an-id")
  end

  test "find! ok" do
    assert %Post{id: 1} = Repository.find!(Post, 1)
  end

  test "find! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Repository.find!(Post, "not-an-id")
    end
  end

  test "create :ok" do
    post = Post.valid()
    {:ok, saved_post} = Repository.save(post)
    {:ok, fetched_post} = Repository.find(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create :error" do
    post = Post.invalid()
    assert {:error, %Error.ResourceInvalid{}} = Repository.save(post)
  end

  test "create! ok" do
    post = Post.valid()
    saved_post = Repository.save!(post)
    fetched_post = Repository.find!(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create! raise" do
    assert_raise Error.ResourceInvalid, fn ->
      Post.invalid() |> Repository.save!()
    end
  end

  test "update :ok" do
    {:ok, post} = Post.valid() |> Repository.save()
    %{post | name: "updated"} |> Repository.save()
    {:ok, updated_post} = Repository.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update :error" do
    assert {:error, %Error.ResourceNotFound{}} = Post.non_existent() |> Repository.save()
  end

  test "update! ok" do
    post = Post.valid() |> Repository.save!()
    %{post | name: "updated"} |> Repository.save!()
    updated_post = Repository.find!(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Post.non_existent() |> Repository.save!()
    end
  end

  test "delete :ok" do
    {:ok, post} = Post.build(name: "Hello from test") |> Repository.save()

    assert {:ok, _} = Repository.delete(post)
    assert {:error, %Resty.Error.ResourceNotFound{}} = Repository.find(Post, post.id)
  end

  test "delete :error" do
    assert {:error, %Error.ResourceNotFound{}} =
             Post.non_existent()
             |> Repository.delete()
  end

  test "delete! ok" do
    {:ok, post} = Post.valid() |> Repository.save()

    Repository.delete!(post)

    assert {:error, %Resty.Error.ResourceNotFound{}} = Repository.find(Post, post.id)
  end

  test "delete! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Post.non_existent() |> Repository.delete!()
    end
  end
end
