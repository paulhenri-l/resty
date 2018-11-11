defmodule Resty.RepoTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Error
  alias Resty.Repo

  test "find :ok" do
    assert {:ok, %Post{id: 1}} = Repo.find(Post, 1)
  end

  test "find :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(Post, "not-an-id")
  end

  test "find! ok" do
    assert %Post{id: 1} = Repo.find!(Post, 1)
  end

  test "find! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(Post, "not-an-id")
    end
  end

  test "exists? :ok" do
    assert {:ok, true} = Repo.exists?(Post, 1)
    assert {:ok, true} = Post.existing() |> Repo.exists?()

    assert {:ok, false} = Repo.exists?(Post, "not-an-id")
    assert {:ok, false} = Post.non_existent() |> Repo.exists?()
  end

  test "exists? :error" do
    assert {:error, %Error.BadRequest{}} = Repo.exists?(Post, "bad-request")
    assert {:error, %Error.BadRequest{}} = Post.build(id: "bad-request") |> Repo.exists?()
  end

  test "create :ok" do
    post = Post.valid()
    {:ok, saved_post} = Repo.save(post)
    {:ok, fetched_post} = Repo.find(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create :error" do
    post = Post.invalid()
    assert {:error, %Error.ResourceInvalid{}} = Repo.save(post)
  end

  test "create! ok" do
    post = Post.valid()
    saved_post = Repo.save!(post)
    fetched_post = Repo.find!(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create! raise" do
    assert_raise Error.ResourceInvalid, fn ->
      Post.invalid() |> Repo.save!()
    end
  end

  test "update :ok" do
    {:ok, post} = Post.valid() |> Repo.save()
    %{post | name: "updated"} |> Repo.save()
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update :error" do
    assert {:error, %Error.ResourceNotFound{}} = Post.non_existent() |> Repo.save()
  end

  test "update! ok" do
    post = Post.valid() |> Repo.save!()
    %{post | name: "updated"} |> Repo.save!()
    updated_post = Repo.find!(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Post.non_existent() |> Repo.save!()
    end
  end

  test "delete :ok" do
    {:ok, post_1} = Post.build(name: "Hello from test") |> Repo.save()
    {:ok, post_2} = Post.build(name: "Hello from test") |> Repo.save()

    assert {:ok, _} = Repo.delete(post_1)
    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_1.id)

    assert {:ok, _} = Repo.delete(Post, post_2.id)
    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_2.id)
  end

  test "delete :error" do
    assert {:error, %Error.ResourceNotFound{}} =
             Post.non_existent()
             |> Repo.delete()

    assert {:error, %Error.ResourceNotFound{}} = Repo.delete(Post, "non_existent")
  end

  test "delete! ok" do
    {:ok, post_1} = Post.valid() |> Repo.save()
    {:ok, post_2} = Post.valid() |> Repo.save()

    Repo.delete!(post_1)
    Repo.delete!(Post, post_2.id)

    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_1.id)
    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_2.id)
  end

  test "delete! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Post.non_existent() |> Repo.delete!()
    end

    assert_raise Error.ResourceNotFound, fn ->
      Repo.delete!(Post, "non_existent")
    end
  end
end
