# This copy pasta sucks, but defining types thanks to macros seems a bit hard.
defmodule Resty.Error do
  @moduledoc """
  A bit of metaprogramming to define all of `Resty`'s exceptions.
  """

  @type t ::
          Resty.Error.ConnectionError.t()
          | Resty.Error.ClientError.t()
          | Resty.Error.ServerError.t()
          | Resty.Error.Redirection.t()
          | Resty.Error.BadRequest.t()
          | Resty.Error.UnauthorizedAccess.t()
          | Resty.Error.ForbiddenAccess.t()
          | Resty.Error.ResourceNotFound.t()
          | Resty.Error.MethodNotAllowed.t()
          | Resty.Error.ResourceConflict.t()
          | Resty.Error.ResourceGone.t()
          | Resty.Error.ResourceInvalid.t()
end

errors = [
  {Resty.Error.ConnectionError, nil, ""},
  {Resty.Error.ClientError, nil, ""},
  {Resty.Error.ServerError, 500, ""},
  {Resty.Error.Redirection, 302, ""},
  {Resty.Error.BadRequest, 400, ""},
  {Resty.Error.UnauthorizedAccess, 401, ""},
  {Resty.Error.ForbiddenAccess, 403, ""},
  {Resty.Error.ResourceNotFound, 404, ""},
  {Resty.Error.MethodNotAllowed, 405, ""},
  {Resty.Error.ResourceConflict, 409, ""},
  {Resty.Error.ResourceGone, 410, ""},
  {Resty.Error.ResourceInvalid, 422, ""}
]

for {error, code, message} <- errors do
  content =
    quote do
      defexception code: unquote(code), message: unquote(message)

      @type t() :: %__MODULE__{
              code: integer() | any(),
              message: String.t() | any()
            }

      @doc """
      Create a new exception with the given values.
      """
      def new(opts \\ []) do
        %__MODULE__{} |> struct(opts)
      end
    end

  Module.create(error, content, Macro.Env.location(__ENV__))
end
