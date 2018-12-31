defmodule Resty.Connection.Mock do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro mock(:get, url, response) do
    quote do
      def send(%{method: :get, url: unquote(url)}, _) do
        unquote(response)
      end
    end
  end

  defmacro mock(:post, url, response) do
    quote do
      def send(%{method: :post, url: unquote(url), body: body}, _) do
        unquote(response)
      end
    end
  end

  defmacro mock(:patch, url, response) do
    quote do
      def send(%{method: :patch, url: unquote(url), body: body}, _) do
        unquote(response)
      end
    end
  end

  defmacro mock(:put, url, response) do
    quote do
      def send(%{method: :put, url: unquote(url), body: body}, _) do
        unquote(response)
      end
    end
  end

  defmacro mock(:delete, url, response) do
    quote do
      def send(%{method: :delete, url: unquote(url)}, _) do
        unquote(response)
      end
    end
  end

  defmacro mock(:post, url) do
    quote do
      def send(%{method: :post, url: unquote(url), body: body}, _) do
        {:ok, body}
      end
    end
  end

  defmacro mock(:patch, url) do
    quote do
      def send(%{method: :patch, url: unquote(url), body: body}, _) do
        {:ok, body}
      end
    end
  end

  defmacro mock(:put, url) do
    quote do
      def send(%{method: :put, url: unquote(url), body: body}, _) do
        {:ok, body}
      end
    end
  end

  defmacro mock(:delete, url) do
    quote do
      def send(%{method: :delete, url: unquote(url)}, _) do
        {:ok, ""}
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def send(req, _) do
        raise """
        No mock defined for this request.

        method: #{req.method}
        url: #{req.url}
        """
      end
    end
  end
end
