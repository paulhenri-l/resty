# Resty

[![Build Status](https://travis-ci.org/paulhenri-l/resty.svg?branch=master)](https://travis-ci.org/paulhenri-l/resty)
[![Code coverage](https://codecov.io/gh/paulhenri-l/resty/branch/master/graph/badge.svg)](https://codecov.io/gh/paulhenri-l/resty)

Resty aims to be like [ActiveResource](https://github.com/rails/activeresource)
but for Elixir.

ActiveResource is great and as I do not intend to reinvent the wheel a lot of
the concepts found in ActiveResource have just been ported to this library so
you should feel *kinda* right at home.

If you do not know what ActiverResource is, it is like an ORM but instead of
using a database it works with REST APIs.

> Model classes are mapped to remote REST resources by Active Resource much the
> same way Active Record maps model classes to database tables. When a request
> is made to a remote resource, a REST JSON request is generated, transmitted,
> and the result received and serialized into a usable Ruby object.
>
> -- <cite>ActiveResource README</cite>

## Installation

First, add Resty to your mix.exs dependencies:

```elixir
def deps do
  [{:resty, "~> 0.12.0"}]
end
```

and run `mix deps.get`.

## Configuration

Out of the box Resty works without needing you to configure anything. But if
you want to change the defaults you can do it in your config.exs file.
Configurable options can be found in the [documentation](https://hexdocs.pm/resty/Resty.html).

## Usage

### Creating a resource

First thing first. In order to use Resty and query an API you'll need a
**resource**

Resources can be created thanks to the `Resty.Resource.Base` module.

```elixir
defmodule Post do
  use Resty.Resource.Base

  # On which site is the resource available? This can also be set globally in
  # your config.exs file.
  set_site "https://jsonplaceholder.typicode.com"

  # What is the path to the resource?
  set_resource_path "/posts"

  # What attributes exists on the resource?
  define_attributes [:title, :body, :userId]
end
```

And now we can do CRUD!

### Find

Find will issue a GET request to the resource.

```elixir
{:ok, post} = Post |> Resty.Repo.find(1)

IO.inspect(post) # %Post{id: 1, title: "The title", body: "The body", userId: 1}
```

#### Under the hood

```
# Request -> GET https://jsonplaceholder.typicode.com/posts/1
# Response -> {"id": 1, "title": "The title", "body": "The body", "userId": 1}
```

### Create

Create will issue a POST request to the resource

```elixir
{:ok, post} = Post.build(title: "The title", body: "The body", userId: 1) |> Resty.Repo.save()

IO.inspect(post) # %Post{id: 1, title: "The title", body: "The body", userId: 1}
```

#### Under the hood

```
# Request -> POST https://jsonplaceholder.typicode.com/posts
# Request Body -> {"title": "The title", "body": "The body", "userId": 1}
# Response -> {"id": 2, "title": "The title", "body": "The body", "userId": 1}
```

### Update

Update will issue a PUT request to the resource

```elixir
{:ok, post} = Post |> Resty.Repo.find(1)

{:ok, updated_post} = %{post | title: "updated-title"} |> Resty.Repo.save()

IO.inspect(update_post) # %Post{id: 1, title: "updated-title", body: "The body", userId: 1}
```

#### Under the hood

```
# Request -> PUT https://jsonplaceholder.typicode.com/posts/1
# Request Body -> {"title": "updated-title", "body": "The body", "userId": 1}
# Response -> {"id": 1, "title": "updated-title", "body": "The body", "userId": 1}
```

### Delete

Delete will issue a DELETE request to the resource

```elixir
{:ok, post} = Post |> Resty.Repo.find(1)
{:ok, true} = post |> Resty.Repo.delete()
```

#### Under the hood

```
# Request -> DELETE https://jsonplaceholder.typicode.com/posts/1
# Response -> 204 No Content
```

### Associations

Here are the associations that are supported by resty. Do note that associations
won't be automaticaly saved. If you change their values you'll have to manually
save them.

#### BelongTo

Resty is able to automaticaly resolve your belongs to associations.

```elixir
defmodule User do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/users"
  define_attributes [:name, :email]
end

defmodule Post do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/posts"
  define_attributes [:title, :body, :userId]

  belongs_to User, :user, :userId
end

{:ok, post} = Post |> Resty.Repo.find(1)

IO.inspect(post.user) # %User{id: 1, email: "Sincere@april.biz", name: "Leanne Graham"}
```

Under the hood

```
# Request -> GET https://jsonplaceholder.typicode.com/posts/1
# Request -> GET https://jsonplaceholder.typicode.com/users/1
# Response -> {"id": 1, "title": "The title", "body": "The body", "userId": 1}
# Response -> {"id": 1, "email": "Sincere@april.biz", "name": "Leanne Graham"}
```

#### HasOne

Resty is able to automaticaly resolve your has one associations.

*If the association is already in the response body it won't get refetched*

```elixir
defmodule Company do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/users/:user_id/company"
  define_attributes [:name]
end

defmodule User do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/users"
  define_attributes [:name, :email]

  has_one Company, :company, :userId
end

{:ok, user} = User |> Resty.Repo.find(1)

IO.inspect(user.company.name) # Romaguera-Crona
```

Under the hood

```
# Request -> GET https://jsonplaceholder.typicode.com/users/1
# Request -> GET https://jsonplaceholder.typicode.com/users/1/company
# Response -> {"id": 1, "email": "Sincere@april.biz", "name": "Leanne Graham"}
# Response -> {"name": "Romaguera-Crona"}
```

#### HasMany

Resty is able to automaticaly resolve your has many associations.

*If the association is already in the response body it won't get refetched*

```elixir
defmodule Comment do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/posts/:post_id/comments"
  define_attributes [:postId, :body]
end

defmodule Post do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/posts"
  define_attributes [:title, :body]

  has_many Comment, :comments, :postId
end

{:ok, post} = Post |> Resty.Repo.find(1)

IO.inspect(user.post.comments) # [%Comment{name: "id labore ex et quam laborum""} | _]
```

Under the hood

```
# Request -> GET https://jsonplaceholder.typicode.com/posts/1
# Request -> GET https://jsonplaceholder.typicode.com/posts/1/comments
# Response -> {"userId": 1, "id": 1, "title": "...", "body": "..."}
# Response -> [{"postId": 1, "id": 1, "name": "...", "email": "...", "body": "..."}, {...}]
```

### Authentication

Some API will require you to authenticate your requests. Out of the box Resty
support *Basic* and *Bearer* auth.

#### Basic

More informations about this auth strategy can be found [here](https://hexdocs.pm/resty/Resty.Auth.Basic.html)

```elixir
defmodule Post do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/posts"
  define_attributes [:title, :body, :userId]
  with_auth Resty.Auth.Basic, user: "hello", password: "hola"
end
```

#### Bearer token

More informations about this auth strategy can be found [here](https://hexdocs.pm/resty/Resty.Auth.Bearer.html)

```elixir
defmodule Post do
  use Resty.Resource.Base

  set_site "https://jsonplaceholder.typicode.com"
  set_resource_path "/posts"
  define_attributes [:title, :body, :userId]
  with_auth Resty.Auth.Beaer, token: "my-token"
end
```

## Docs

The documentation is available here [https://hexdocs.pm/resty](https://hexdocs.pm/resty)

The most important modules are `Resty.Repo`, `Resty.Resource.Base` and `Resty.Resource`.

## Contributing

If you have any questions about how to use this library feel free to open
an issue :)

If you think that the documentation or the code could be improved open a PR
and I'll happily review it!
