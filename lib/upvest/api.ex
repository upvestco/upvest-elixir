defmodule Upvest.API do
  defmacro __using__(opts) do
    quote do
      import Upvest, only: [request: 4]
      alias Upvest.Client
      @page_size 100

      if :create in unquote(opts) do
        @doc """
        Create a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def create(client, data) do
          request(:post, endpoint(), data, client)
        end
      end

      if :retrieve in unquote(opts) do
        @doc """
        Retrive a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()} by its ID
        """
        def retrieve(client, id) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:get, resource_url, %{}, client)
        end
      end

      if :update in unquote(opts) do
        @doc """
        Update a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def update(client, id, data) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:patch, resource_url, data, client)
        end
      end

      if :list in unquote(opts) do
        @doc """
        List all #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        #TODO: support configurable page size
        """
        def list_n(client, count) do
          results = do_list_n(endpoint(), count, client, [])
          {:ok, results}
        end

        defp do_list_n(url, count, client, acc) do
          {:ok, resp} = request(:get, url, %{}, client)
          next = Map.get(resp, "next")
          acc = acc ++ resp["results"]

          case is_nil(next) or length(acc) == count do
            true ->
              acc

            _ ->
              uri = URI.parse(next)
              params = Map.put(URI.decode_query(uri.query), :page_size, @page_size)
              next_url = URI.parse(next).path |> String.slice(4..-1)
              next_url = "#{next_url}?#{URI.encode_query(params)}"
              do_list_n(next_url, count, client, acc)
          end
        end

        def list(client) do
          results = do_list(endpoint(), client, [])
          # IO.puts inspect(results)
          {:ok, results}
        end

        defp do_list(url, client, acc) do
          {:ok, resp} = request(:get, url, %{page_size: @page_size}, client)
          next = Map.get(resp, "next")
          acc = acc ++ resp["results"]

          case is_nil(next) do
            true ->
              acc

            _ ->
              uri = URI.parse(next)
              params = Map.put(URI.decode_query(uri.query), :page_size, @page_size)
              next_url = URI.parse(next).path |> String.slice(4..-1)
              next_url = "#{next_url}?#{URI.encode_query(params)}"
              do_list(next_url, client, acc)
          end
        end
      end

      if :delete in unquote(opts) do
        @doc """
        Delete a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def delete(client, id) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:delete, resource_url, %{}, client)
        end
      end
    end
  end
end
