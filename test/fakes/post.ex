defmodule Fakes.Post do
  use Resty.Resource

  set_site("site.tld")
  set_path("posts")

  field(:id, :int)
  field(:name, :string)

  def existing, do: build(id: 1)
  def valid, do: build(name: "test")
  def invalid, do: build(name: "invalid")
  def non_existent, do: build(id: "non_existent")
end
