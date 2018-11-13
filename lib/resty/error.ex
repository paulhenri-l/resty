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

      @doc """
      Create a new exception with the given values.
      """
      def new(opts \\ []) do
        %__MODULE__{} |> struct(opts)
      end
    end

  Module.create(error, content, Macro.Env.location(__ENV__))
end
