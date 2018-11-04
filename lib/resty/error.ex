defmodule Resty.Error do
  @callback new(keyword()) :: map()

  defmacro __using__(opts) do
    code = Keyword.get(opts, :code, nil)

    quote do
      defstruct code: unquote(code), message: nil

      def new, do: new([])

      def new(opts) do
        new(opts, %__MODULE__{})
      end

      def new([{:code, value} | t], error) do
        new(t, Map.put(error, :code, value))
      end

      def new([{:message, value} | t], error) do
        new(t, Map.put(error, :message, value))
      end

      def new([], error), do: error
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
