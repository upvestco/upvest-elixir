defmodule Upvest.API do
  defmacro __using__(opts) do
    quote do
      import Upvest, only: [request: 4]
      alias Upvest.Client

      if :create in unquote(opts) do
        @doc """
        Create a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def create(data, client) do
          request(:post, endpoint(), data, client)
        end
      end

      if :retrieve in unquote(opts) do
        @doc """
        Retrive a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()} by its ID
        """
        def retrieve(id, client) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:get, resource_url, %{}, client)
        end
      end

      if :update in unquote(opts) do
        @doc """
        Update a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def update(id, data, client) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:put, resource_url, data, client)
        end
      end

      if :list in unquote(opts) do
        @doc """
        List all #{__MODULE__ |> to_string |> String.split(".") |> List.last()}s
        """
        def list(pagination_opts, client) when is_list(pagination_opts) do
          request(:get, endpoint(), pagination_opts, client)
        end

        def list(client) do
          request(:get, endpoint(), %{}, client)
        end
      end

      if :delete in unquote(opts) do
        @doc """
        Delete a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def delete(id, client) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:delete, resource_url, %{}, client)
        end
      end
    end
  end
end
