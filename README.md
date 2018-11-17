# Resty

[![Build Status](https://travis-ci.org/paulhenri-l/resty.svg?branch=master)](https://travis-ci.org/paulhenri-l/resty)

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
  [{:resty, "~> 0.8.1"}]
end
```

and run `mix deps.get`.

## Configuration

Out of the box Resty works without needing you to configure anything. But if
you want to change the defaults you can do in your config.exs file.
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
  set_site("https://jsonplaceholder.typicode.com")

  # What is the path to the resource?
  set_resource_path("/posts")

  # What attributes exists on the resource?
  define_attributes([:title, :body, :userId])
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

I am working on it, 1.0 won't go out without it.

### Authentication

Some API will require you to authenticate your requests. Out of the box Resty
support *Basic* and *Bearer* auth.

#### Basic

More informations about this auth strategy can be found [here](https://hexdocs.pm/resty/Resty.Auth.Basic.html)

```elixir
defmodule Post do
  use Resty.Resource.Base

  set_site("https://jsonplaceholder.typicode.com")
  set_resource_path("/posts")
  define_attributes([:title, :body, :userId])
  with_auth(Resty.Auth.Basic, user: "hello", password: "hola")
end
```

#### Bearer token

More informations about this auth strategy can be found [here](https://hexdocs.pm/resty/Resty.Auth.Bearer.html)

```elixir
defmodule Post do
  use Resty.Resource.Base

  set_site("https://jsonplaceholder.typicode.com")
  set_resource_path("/posts")
  define_attributes([:title, :body, :userId])
  with_auth(Resty.Auth.Beaer, token: "my-token")
end
```

## Docs

The documentation is available here [https://hexdocs.pm/resty](https://hexdocs.pm/resty)

The most important modules are `Resty.Repo`, `Resty.Resource.Base` and `Resty.Resource`.

## This is a work in progress

If you want to known what I am currently working on you can also have a look at
the open issues.

I'll do my best not to make any backward incompatible changes but as this project
is quite new the api cannot be considered stable yet. I'll stop making these big
changes when we'll hit 1.0. Which should be comming soon.

If you have any comment or suggestion please feel free to open an issue :)
