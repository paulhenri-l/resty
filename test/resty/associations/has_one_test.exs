defmodule Resty.Associations.HasOneTest do
  use ExUnit.Case, async: true

  test "HasOne associations are automatically fetched and loaded" do
    # _address = Resty.Repo.find!(Author.Address, nil, author_id: 1)

    author = Resty.Repo.find!(Author, 1)

    IO.inspect(author)
  end
end
