defmodule Resty.RepoTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Error
  alias Resty.Repo
  alias Fakes.InvalidResource
  alias Fakes.NotFoundResource
  alias Fakes.BadRequestResource

  test "first :ok" do
    assert {:ok, %Post{id: 1}} = Repo.first(Post)
  end

  test "first :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.first(NotFoundResource)
  end

  test "first! ok" do
    assert %Post{id: 1} = Repo.first!(Post)
  end

  test "first! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.first!(NotFoundResource)
    end
  end

  test "last :ok" do
    assert {:ok, %Post{}} = Repo.last(Post)
  end

  test "last :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.last(NotFoundResource)
  end

  test "last! ok" do
    assert %Post{} = Repo.last!(Post)
  end

  test "last! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.last!(NotFoundResource)
    end
  end

  test "all :ok" do
    assert {:ok, [%Post{id: 1} | _]} = Repo.all(Post)
  end

  test "all :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.all(NotFoundResource)
  end

  test "all! ok" do
    assert [%Post{id: 1} | _] = Repo.all!(Post)
  end

  test "all! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.all!(NotFoundResource)
    end
  end

  test "find :ok" do
    assert {:ok, %Post{id: 1}} = Repo.find(Post, 1)
    assert {:ok, %Post{id: 1}} = Repo.find(Post, :first)
    assert {:ok, %Post{}} = Repo.find(Post, :last)
    assert {:ok, [%Post{id: 1} | _]} = Repo.find(Post, :all)
  end

  test "find :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(NotFoundResource, 1)
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(NotFoundResource, :first)
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(NotFoundResource, :last)
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(NotFoundResource, :all)
  end

  test "find! ok" do
    assert %Post{id: 1} = Repo.find!(Post, 1)
    assert %Post{id: 1} = Repo.find!(Post, :first)
    assert %Post{} = Repo.find!(Post, :last)
    assert [%Post{id: 1} | _] = Repo.find!(Post, :all)
  end

  test "find! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(NotFoundResource, 1)
    end

    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(NotFoundResource, :first)
    end

    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(NotFoundResource, :last)
    end

    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(NotFoundResource, :all)
    end
  end

  test "exists? :ok" do
    assert {:ok, true} = Repo.exists?(Post, 1)
    assert {:ok, true} = Post.build(id: 1) |> Repo.exists?()

    assert {:ok, false} = Repo.exists?(NotFoundResource, 1)
    assert {:ok, false} = NotFoundResource.build() |> Repo.exists?()
  end

  test "exists? :error" do
    assert {:error, %Error.BadRequest{}} = Repo.exists?(BadRequestResource, 1)
    assert {:error, %Error.BadRequest{}} = BadRequestResource.build() |> Repo.exists?()
  end

  test "create :ok" do
    post = Post.build()
    {:ok, saved_post} = Repo.save(post)
    {:ok, fetched_post} = Repo.find(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create :error" do
    assert {:error, %Error.ResourceInvalid{}} = InvalidResource.build() |> Repo.save()
  end

  test "create! ok" do
    post = Post.build()
    saved_post = Repo.save!(post)
    fetched_post = Repo.find!(Post, saved_post.id)

    assert post.name == saved_post.name
    assert post.name == fetched_post.name
  end

  test "create! raise" do
    assert_raise Error.ResourceInvalid, fn ->
      InvalidResource.build() |> Repo.save!()
    end
  end

  test "update :ok" do
    {:ok, post} = Post.build() |> Repo.save()
    %{post | name: "updated"} |> Repo.save()
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update :error" do
    assert {:error, %Error.ResourceNotFound{}} = NotFoundResource.build() |> Repo.save()
  end

  test "update! ok" do
    post = Post.build() |> Repo.save!()
    %{post | name: "updated"} |> Repo.save!()
    updated_post = Repo.find!(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      NotFoundResource.build() |> Repo.save!()
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
             NotFoundResource.build()
             |> Repo.delete()

    assert {:error, %Error.ResourceNotFound{}} = Repo.delete(NotFoundResource, 1)
  end

  test "delete! ok" do
    {:ok, post_1} = Post.build() |> Repo.save()
    {:ok, post_2} = Post.build() |> Repo.save()

    Repo.delete!(post_1)
    Repo.delete!(Post, post_2.id)

    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_1.id)
    assert {:error, %Resty.Error.ResourceNotFound{}} = Repo.find(Post, post_2.id)
  end

  test "delete! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      NotFoundResource.build() |> Repo.delete!()
    end

    assert_raise Error.ResourceNotFound, fn ->
      Repo.delete!(NotFoundResource, 1)
    end
  end
end
