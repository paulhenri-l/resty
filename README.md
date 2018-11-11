# Resty

[![Build Status](https://travis-ci.org/paulhenri-l/resty.svg?branch=master)](https://travis-ci.org/paulhenri-l/resty)

Resty aims to be like [ActiveResource](https://github.com/rails/activeresource)
but for Elixir. ActiveResource is great and as I do not intend to reinvent the
wheel a lot of the concepts found in ActiveResource have just been ported to
this library so you should feel *kinda* right at home.

## Basic usage

Here's how you would use Resty to query a rails API.

```elixir
defmodule Post do
  use Resty.Resource

  set_site("site.tld")
  set_resource_path("posts")

  attribute(:id)
  attribute(:name)
  attribute(:body)
end

{:ok, post} = Resty.Repo.find(Post, 1)

IO.inspect(post.id)
IO.inspect(post.name)
IO.inspect(post.body)
```

## Resource and Repository

Almost all of the relevant functions can be found in the `Resty.Resource` and
`Resty.Repo` modules.

## Docs

The documentation is available here [https://hexdocs.pm/resty](https://hexdocs.pm/resty/0.1.1)

## This is a work in progress

This library does not implement all of the ActiveResource's features yet. I'll
be adding more and more features as I need them. If you need something feel
free to open a PR.
