defmodule Resty.Error do
  @moduledoc """
  This module is used in order to define all of `Resty`'s exceptions.
  """

  @typedoc "A Resty exception"
  @type t :: %{
          code: integer() | any(),
          message: String.t() | any()
        }

  @doc """
  Create a new exception with the given values.

  ```
  DummyError.new(code: 500, message: "ServerError")
  ```
  """
  @callback new(opts :: Enum.t()) :: map()

  @doc """
  Turn the current module into a Resty exception.

  ## Options
  - `:code`: The default error code.
  - `:message`: The default error message (defaults to "error").

  ## Usage

  Given a DummyError

  ```
  defmodule DummyError do
    use Resty.Error, code: 500, message: "dummy"
  end
  ```

  You can then do this

  ```
  iex> DummyError.new()
  %DummyError{code: 500, message: "dummy"}
  ```
  """
  @spec __using__(Keyword.t()) :: none()
  defmacro __using__(opts) do
    code = Keyword.get(opts, :code, nil)
    message = Keyword.get(opts, :message, "Error")

    quote do
      @behaviour Resty.Error
      defexception code: unquote(code),
                   message: unquote(message)

      def new, do: %__MODULE__{}

      def new(opts) do
        new() |> struct(opts)
      end
    end
  end
end

defmodule Resty.Error.ConnectionError do
  use Resty.Error
end

defmodule Resty.Error.ClientError do
  use Resty.Error
end

defmodule Resty.Error.ServerError do
  use Resty.Error, code: 500
end

defmodule Resty.Error.Redirection do
  use Resty.Error, code: 302
end

defmodule Resty.Error.BadRequest do
  use Resty.Error, code: 400
end

defmodule Resty.Error.UnauthorizedAccess do
  use Resty.Error, code: 401
end

defmodule Resty.Error.ForbiddenAccess do
  use Resty.Error, code: 403
end

defmodule Resty.Error.ResourceNotFound do
  use Resty.Error, code: 404
end

defmodule Resty.Error.MethodNotAllowed do
  use Resty.Error, code: 405
end

defmodule Resty.Error.ResourceConflict do
  use Resty.Error, code: 409
end

defmodule Resty.Error.ResourceGone do
  use Resty.Error, code: 410
end

defmodule Resty.Error.ResourceInvalid do
  use Resty.Error, code: 422
end
