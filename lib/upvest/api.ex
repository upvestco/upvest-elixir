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
        List all #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        #TODO: support configurable page size
        """
        def list(count, client) do
          results = list_n(endpoint(), count, client, [])
          {:ok, results}
        end

        defp list_n(url, count, client, acc) do
          {:ok, resp} = request(:get, url, %{}, client)
          next = Map.get(resp, "next")

          case is_nil(next) or length(acc) >= count do
            true ->
              acc

            _ ->
              uri = URI.parse(next)
              params = Map.put(URI.decode_query(uri.query), :page_size, 100)
              next_url = URI.parse(next).path |> String.slice(4..-1)
              next_url = "#{next_url}?#{URI.encode_query(params)}"
              list_n(next_url, count, client, acc ++ resp["results"])
          end
        end

        def list(client) do
          results = list(endpoint(), client, [])
          {:ok, results}
        end

        defp list(url, client, acc) do
          {:ok, resp} = request(:get, url, %{}, client)
          next = Map.get(resp, "next")

          case is_nil(next) do
            true ->
              acc

            _ ->
              uri = URI.parse(next)
              params = Map.put(URI.decode_query(uri.query), :page_size, 100)
              next_url = URI.parse(next).path |> String.slice(4..-1)
              next_url = "#{next_url}?#{URI.encode_query(params)}"
              list(next_url, client, acc ++ resp["results"])
          end
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
