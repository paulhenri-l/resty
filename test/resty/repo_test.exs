defmodule Resty.RepoTest do
  use ExUnit.Case, async: true
  alias Resty.Repo
  alias Resty.Error

  test "first :ok" do
    assert {:ok, %Post{id: 1}} = Repo.first(Post)
    assert {:ok, nil} == Repo.first(Subscriber)
  end

  test "first :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.first(Like)
  end

  test "first! ok" do
    assert %Post{id: 1} = Repo.first!(Post)
    assert nil == Repo.first!(Subscriber)
  end

  test "first! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.first!(Like)
    end
  end

  test "last :ok" do
    assert {:ok, %Post{id: 3}} = Repo.last(Post)
    assert {:ok, nil} == Repo.last(Subscriber)
  end

  test "last :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.last(Like)
  end

  test "last! ok" do
    assert %Post{id: 3} = Repo.last!(Post)
    assert nil == Repo.last!(Subscriber)
  end

  test "last! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.last!(Like)
    end
  end

  test "show :ok" do
    assert {:ok, [%Post{id: 1} | _]} = Repo.show(Post)
    assert {:ok, []} = Repo.show(Subscriber)
  end

  test "show :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.show(Like)
  end

  test "show! ok" do
    assert [%Post{id: 1} | _] = Repo.show!(Post)
    assert [] = Repo.all!(Subscriber)
  end

  test "show! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.all!(Like)
    end
  end

  test "all :ok" do
    assert {:ok, [%Post{id: 1} | _]} = Repo.all(Post)
    assert {:ok, []} = Repo.all(Subscriber)
  end

  test "all :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.all(Like)
  end

  test "all! ok" do
    assert [%Post{id: 1} | _] = Repo.all!(Post)
    assert [] = Repo.all!(Subscriber)
  end

  test "all! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.all!(Like)
    end
  end

  test "find :ok" do
    assert {:ok, %Post{id: 1}} = Repo.find(Post, 1)
  end

  test "find :error" do
    assert {:error, %Error.ResourceNotFound{}} = Repo.find(Subscriber, 1)
  end

  test "find! ok" do
    assert %Post{id: 1} = Repo.find!(Post, 1)
  end

  test "find! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Repo.find!(Subscriber, 1)
    end
  end

  test "create :ok" do
    post = Post.build(name: "name")

    {:ok, saved_post} = Repo.save(post)

    assert post.name == saved_post.name
  end

  test "create :error" do
    assert {:error, %Error.ResourceNotFound{}} = Like.build() |> Repo.save()
  end

  test "create! ok" do
    post = Post.build(name: "name")

    saved_post = Repo.save!(post)

    assert post.name == saved_post.name
  end

  test "create! raise" do
    assert_raise Error.ResourceNotFound, fn ->
      Like.build() |> Repo.save!()
    end
  end

  test "update :ok" do
    {:ok, post} = Repo.find(Post, 1)

    {:ok, updated_post} = %{post | name: "updated"} |> Repo.save()

    assert "updated" == updated_post.name
  end

  test "update :error" do
    {:ok, post} = Repo.find(Post, 2)

    assert {:error, %Error.ResourceInvalid{}} = post |> Repo.save()
  end

  test "update! ok" do
    {:ok, post} = Repo.find(Post, 1)

    updated_post = %{post | name: "updated"} |> Repo.save!()

    assert "updated" == updated_post.name
  end

  test "update! raise" do
    assert_raise Error.ResourceInvalid, fn ->
      {:ok, post} = Repo.find(Post, 2)

      post |> Repo.save!()
    end
  end

  test "update singular :ok" do
    {:ok, post} = Repo.find(Post, 1)

    {:ok, updated_post} = %{post | name: "updated"} |> Repo.update()

    assert "updated" == updated_post.name
  end

  test "update_attribute :ok" do
    {:ok, post} = Repo.find(Post, 1)

    {:ok, updated_post} = Repo.update_attribute(post, :name, "updated")

    assert "updated" == updated_post.name
  end

  test "update_attribute :error" do
    {:ok, post} = Repo.find(Post, 2)

    update_result = post |> Repo.update_attribute(:name, "hey!")

    assert {:error, %Error.ResourceInvalid{}} = update_result
  end

  test "update_attribute! ok" do
    {:ok, post} = Repo.find(Post, 1)

    updated_post = Repo.update_attribute!(post, :name, "updated")

    assert "updated" == updated_post.name
  end

  test "update_attribute! error" do
    assert_raise Error.ResourceInvalid, fn ->
      {:ok, post} = Repo.find(Post, 2)

      post |> Repo.update_attribute!(:name, "Hey!")
    end
  end

  test "update_attributes :ok" do
    {:ok, post} = Repo.find(Post, 1)

    {:ok, updated_post} = Repo.update_attributes(post, name: "updated")

    assert "updated" == updated_post.name
  end

  test "update_attributes :error" do
    {:ok, post} = Repo.find(Post, 2)

    update_result = post |> Repo.update_attributes(name: "hey!")

    assert {:error, %Error.ResourceInvalid{}} = update_result
  end

  test "update_attributes! ok" do
    {:ok, post} = Repo.find(Post, 1)

    updated_post = Repo.update_attributes!(post, name: "updated")

    assert "updated" == updated_post.name
  end

  test "update_attributes! error" do
    assert_raise Error.ResourceInvalid, fn ->
      {:ok, post} = Repo.find(Post, 2)

      post |> Repo.update_attributes!(name: "Hey!")
    end
  end

  test "delete :ok" do
    {:ok, post} = Repo.find(Post, 1)

    assert {:ok, true} = Repo.delete(post)
  end

  test "delete :error" do
    {:ok, post} = Repo.find(Post, 2)

    delete_response = post |> Repo.delete()

    assert {:error, %Error.ForbiddenAccess{}} = delete_response
  end

  test "delete! ok" do
    {:ok, post} = Repo.find(Post, 1)

    assert true = Repo.delete!(post)
  end

  test "delete! raise" do
    assert_raise Error.ForbiddenAccess, fn ->
      {:ok, post} = Repo.find(Post, 2)

      Repo.delete!(post)
    end
  end

  test "exists? :ok" do
    assert {:ok, true} = Repo.exists?(Post, 1)
    assert {:ok, true} = Post.build(id: 1) |> Repo.exists?()

    assert {:ok, false} = Repo.exists?(Subscriber, 1)
    assert {:ok, false} = Subscriber.build(id: 1) |> Repo.exists?()
  end

  test "exists? :error" do
    assert {:error, %Error.ForbiddenAccess{}} = Repo.exists?(Admin, 1)
  end

  test "reload :ok" do
    {:ok, initial_post} = Repo.find(Post, 1)

    edited_post = %{initial_post | name: "changed"}

    {:ok, reloaded_post} = Repo.reload(edited_post)

    assert edited_post.name != initial_post.name
    assert reloaded_post.name == initial_post.name
  end

  test "reload :error" do
    assert {:error, %Error.ResourceNotFound{}} = Like.build(id: 1) |> Repo.reload()
  end

  test "reload! ok" do
    {:ok, initial_post} = Repo.find(Post, 1)

    edited_post = %{initial_post | name: "changed"}

    reloaded_post = Repo.reload!(edited_post)

    assert edited_post.name != initial_post.name
    assert reloaded_post.name == initial_post.name
  end

  test "reload! error" do
    assert_raise Error.ResourceNotFound, fn ->
      Like.build(id: 1) |> Repo.reload!()
    end
  end
end
