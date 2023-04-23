defmodule Qdrant.Api.Http.Client do
  @moduledoc """
  Qdrant.Api.Client is a Tesla-based client for the Qdrant API.
  The module provides methods for interacting with the Qdrant API server.

  ## Example
      iex> Qdrant.Api.Client.get("/collections")
      {:ok, %Tesla.Env{status: 200, body: %{"collections" => []}}}

  Or as a macro:

      iex> use Qdrant.Api.Http.Client
      iex> scope("/collections")
      iex> get("")
      # The path is relative to the scope path set above ("/collections")
      # and not the base url set in the config file.
      # This is so that you don't have to repeat the scope path in every request just the relative path.
      {:ok, %Tesla.Env{status: 200, body: %{"collections" => [...]}}}

  """

  defmacro __using__(_opts) do
    quote do
      use Tesla, docs: false
      plug Tesla.Middleware.JSON
      plug Tesla.Middleware.BaseUrl, base_url()
      plug Tesla.Middleware.Headers, [{"api-key", api_key()}]

      defp base_url, do: "#{api_url()}:#{port()}#{api_path()}"

      defp api_url do
        case Application.get_env(:qdrant, :database_url) do
          nil -> raise "Qdrant database url is not set"
          base_url -> base_url
        end
      end

      defp port do
        case Application.get_env(:qdrant, :port) do
          nil -> raise "Qdrant database port is not set"
          port -> port
        end
      end

      defp api_key do
        case Application.get_env(:qdrant, :api_key) do
          nil -> raise "Qdrant api key is not set"
          api_key -> api_key
        end
      end

      import(Qdrant.Api.Http.Client, only: [scope: 1])
    end
  end

  @doc false
  defmacro scope(path) do
    quote do
      def api_path, do: unquote(path)
    end
  end
end
