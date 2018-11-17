defmodule Resty.Connection.HTTPoison do
  alias Resty.Request

  @moduledoc """
  Default `Resty.Connection` implementation. It will use `HTTPoison` in order
  to query the web API.

  ## Params

  All the parameters will be sent to HTTPoison as the `options` you can know
  more about the supported options here: `HTTPoison.Request`

  ## Usage

  As this is the default you should not have to manually set it except if you
  have changed the default connection in your config.exs file or if you want
  to set specific options/params.

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    set_connection(Resty.Connection.HTTPoison, timeout: 8000)
  end
  ```

  You can also define in your config.exs file default options to be sent with
  each request.

  ```
  config :resty, Resty.Connection.HTTPoison, timeout: 8000
  ```

  Thus making it possible to use `Resty.Resource.Base.set_connection/1`

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    set_connection(Resty.Connection.HTTPoison)
  end
  ```
  """

  @doc false
  def send(%Request{} = request, params) do
    request
    |> to_poison_request()
    |> add_httpoison_options(params)
    |> HTTPoison.request()
    |> process_response()
  end

  defp to_poison_request(%Request{} = request) do
    %HTTPoison.Request{
      method: request.method,
      url: request.url,
      body: request.body,
      headers: request.headers,
      options: [],
      params: %{}
    }
  end

  defp add_httpoison_options(request, []) do
    options = Application.get_env(:resty, __MODULE__, [])

    %{request | options: options}
  end

  defp add_httpoison_options(request, options) do
    %{request | options: options}
  end

  defp process_response({:error, exception}) do
    {:error, Resty.Error.ConnectionError.new(message: exception.reason)}
  end

  defp process_response({:ok, %{status_code: status_code, body: body}})
       when status_code in [301, 302, 303, 307] do
    {:error, Resty.Error.Redirection.new(code: status_code, message: body)}
  end

  defp process_response({:ok, %{status_code: status_code, body: body}})
       when status_code >= 200 and status_code < 400 do
    {:ok, body}
  end

  defp process_response({:ok, %{status_code: 400, body: body}}) do
    {:error, Resty.Error.BadRequest.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 401, body: body}}) do
    {:error, Resty.Error.UnauthorizedAccess.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 403, body: body}}) do
    {:error, Resty.Error.ForbiddenAccess.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 404, body: body}}) do
    {:error, Resty.Error.ResourceNotFound.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 405, body: body}}) do
    {:error, Resty.Error.MethodNotAllowed.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 409, body: body}}) do
    {:error, Resty.Error.ResourceConflict.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 410, body: body}}) do
    {:error, Resty.Error.ResourceGone.new(message: body)}
  end

  defp process_response({:ok, %{status_code: 422, body: body}}) do
    {:error, Resty.Error.ResourceInvalid.new(message: body)}
  end

  defp process_response({:ok, %{status_code: status_code, body: body}})
       when status_code >= 400 and status_code < 500 do
    {:error, Resty.Error.ClientError.new(code: status_code, message: body)}
  end

  defp process_response({:ok, %{status_code: status_code, body: body}})
       when status_code >= 500 and status_code < 600 do
    {:error, Resty.Error.ServerError.new(code: status_code, message: body)}
  end

  defp process_response({:ok, %{status_code: status_code, body: body}}) do
    {:error,
     Resty.Error.ConnectionError.new(
       code: status_code,
       message: "Unknown response code, body was: #{body}"
     )}
  end
end
