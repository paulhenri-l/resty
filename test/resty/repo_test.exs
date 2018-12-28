defmodule Resty.RepoTest do
  use ExUnit.Case, async: true

  alias Fakes.Post
  alias Resty.Error
  alias Resty.Repo
  alias Fakes.InvalidResource
  alias Fakes.NotFoundResource
  alias Fakes.BadRequestResource
  alias Fakes.EmptyResource

  test "first :ok" do
    assert {:ok, %Post{id: 1}} = Repo.first(Post)
    assert {:ok, nil} == Repo.first(EmptyResource)
  end

  test "first :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.first(NotFoundResource)
  end

  test "first! ok" do
    assert %Post{id: 1} = Repo.first!(Post)
    assert nil == Repo.first!(EmptyResource)
  end

  test "first! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.first!(NotFoundResource)
    end
  end

  test "last :ok" do
    assert {:ok, %Post{}} = Repo.last(Post)
    assert {:ok, nil} == Repo.last(EmptyResource)
  end

  test "last :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.last(NotFoundResource)
  end

  test "last! ok" do
    assert %Post{} = Repo.last!(Post)
    assert nil == Repo.last!(EmptyResource)
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
  end

  test "find :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(NotFoundResource, 1)
  end

  test "find! ok" do
    assert %Post{id: 1} = Repo.find!(Post, 1)
  end

  test "find! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(NotFoundResource, 1)
    end
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

  test "update_attribute :ok" do
    {:ok, post} = Post.build() |> Repo.save()
    {:ok, %Post{}} = Repo.update_attribute(post, :name, "updated")
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update_attribute :error" do
    assert {:error, %Error.ResourceNotFound{}} =
             NotFoundResource.build()
             |> Repo.update_attribute(:name, "hey!")
  end

  test "update_attribute! ok" do
    {:ok, post} = Post.build() |> Repo.save()
    %Post{} = Repo.update_attribute!(post, :name, "updated")
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update_attribute! error" do
    assert_raise Error.ResourceNotFound, fn ->
      NotFoundResource.build() |> Repo.update_attribute!(:name, "Hey!")
    end
  end

  test "update_attributes :ok" do
    {:ok, post} = Post.build() |> Repo.save()
    {:ok, %Post{}} = Repo.update_attributes(post, name: "updated")
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update_attributes :error" do
    assert {:error, %Error.ResourceNotFound{}} =
             NotFoundResource.build()
             |> Repo.update_attributes(name: "hey!")
  end

  test "update_attributes! ok" do
    {:ok, post} = Post.build() |> Repo.save()
    %Post{} = Repo.update_attributes!(post, name: "updated")
    {:ok, updated_post} = Repo.find(Post, post.id)

    assert "updated" == updated_post.name
  end

  test "update_attributes! error" do
    assert_raise Error.ResourceNotFound, fn ->
      NotFoundResource.build() |> Repo.update_attributes!(name: "Hey!")
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

  test "reload :ok" do
    {:ok, initial_post} = Post.build() |> Repo.save()

    Repo.update_attributes!(initial_post, name: "updated")
    {:ok, reloaded_post} = Repo.reload(initial_post)

    assert reloaded_post.name != initial_post.name
    assert "updated" == reloaded_post.name
  end

  test "reload :error" do
    assert {:error, %Error.ResourceNotFound{}} = NotFoundResource.build() |> Repo.reload()
  end

  test "reload! ok" do
    {:ok, initial_post} = Post.build() |> Repo.save()

    Repo.update_attributes!(initial_post, name: "updated")
    reloaded_post = Repo.reload!(initial_post)

    assert reloaded_post.name != initial_post.name
    assert "updated" == reloaded_post.name
  end

  test "reload! error" do
    assert_raise Error.ResourceNotFound, fn ->
      NotFoundResource.build() |> Repo.reload!()
    end
  end
end
