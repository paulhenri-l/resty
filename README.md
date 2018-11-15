# Resty

[![Build Status](https://travis-ci.org/paulhenri-l/resty.svg?branch=master)](https://travis-ci.org/paulhenri-l/resty)

Resty aims to be like [ActiveResource](https://github.com/rails/activeresource)
but for Elixir. ActiveResource is great and as I do not intend to reinvent the
wheel a lot of the concepts found in ActiveResource have just been ported to
this library so you should feel *kinda* right at home.

## Installation

First, add Resty to your mix.exs dependencies:

```elixir
def deps do
  [{:resty, "~> 0.5.0"}]
end
```

and run `mix deps.get`.

## Basic usage

Here's how you would use Resty to query a rails API.

```elixir
defmodule Post do
  use Resty.Resource.Base

  set_site("site.tld")
  set_resource_path("/posts")

  define_attributes([:id, :name, :body])
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

The documentation is available here [https://hexdocs.pm/resty](https://hexdocs.pm/resty)

## This is a work in progress

This library does not implement all of the ActiveResource's features yet. I'll
be adding more and more features as I need them. If you absolutely need something
feel free to open a PR.

If you want to known what I am currently working on you can also have a look at
the open issues.

I'll do my best not to make any backward incompatible changes but as this project
is quite new the api cannot be considered stable yet. I'll stop making these big
changes when we'll hit 1.0. Which should be comming soon.

I'll do my best to document the code as we'll get near v1.0
