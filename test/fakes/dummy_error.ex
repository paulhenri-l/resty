defmodule DummyError do
  @moduledoc false
  use Resty.Error, code: 500, message: "dummy"
end
