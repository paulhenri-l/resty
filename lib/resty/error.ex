defmodule Resty.Error do
  @type t :: %{
          code: any(),
          message: any()
        }

  @callback new(keyword()) :: map()

  defmacro __using__(opts) do
    code = Keyword.get(opts, :code, nil)

    quote do
      @behaviour Resty.Error
      defexception code: unquote(code), message: nil

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
