defmodule Resty.Associations.HasOneTest do
  use ExUnit.Case, async: true

  alias Resty.Associations.LoadError

  test "HasOne associations are automatically fetched and loaded" do
    author = Resty.Repo.find!(Author, 1)

    assert author.address.city == "Somewhere"
  end

  test "HasOne associations are not loaded if they result in an error" do
    author = Resty.Repo.find!(Author, 3)

    assert author.address == %LoadError{
             error: %Resty.Error.ResourceNotFound{code: 404, message: ""}
           }
  end
end
