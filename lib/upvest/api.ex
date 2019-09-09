defmodule Upvest.API do
  @moduledoc """
  Shared utilities for interacting with the Upvest API.

  It contains shared implementations of endpoints methods for 
  creating, listing, retrieving and deleting resources. Where possible, 
  transforms the raw result from the Upvest API into a final struct. This is achieved 
  through the use of the `Upvest.Utils.to_struct/2`.

  Intended for internal use by Upvest endpoint modules.

  An Upvest endpoint module is usually mappped to an Upvest resource, 
  containing logic for interacting with the associated resource.

  To implement this behaviour, simply add `use Upvest.API, [list_of_methods]` to the top of
  the entity module and make sure it defines a struct mapped to the Upvest resource. 
  The parameter to the `use Upvest.API` construct is a list of HTTP 
  methods you want to expose in the module:

  * create/2 - create a new resource
  * retrive/2 - retrieve a resource
  * update/3 - update a resource
  * delete/2 - delete a resource
  * list/1 - list all resources
  * list_n/2 - list all resources, capped to specified limit
  """
  defmacro __using__(opts) do
    quote do
      import Upvest, only: [request: 4]
      import Upvest.Utils, only: [to_struct: 2, sprintf: 2]
      alias Upvest.Client
      alias __MODULE__

      @type t :: %__MODULE__{}

      @page_size 100

      if :create in unquote(opts) do
        @doc """
        Create a(n) #{__MODULE__ |> Module.split() |> List.last()}
        """
        def create(client, data) do
          request(:post, endpoint(), data, client)
        end
      end

      if :retrieve in unquote(opts) do
        @doc """
        Retrive a(n) #{__MODULE__ |> Module.split() |> List.last()} by its ID
        """
        @spec retrieve(Client.t(), binary()) :: {:ok, __MODULE__.t()} | {:error, Upvest.error()}
        def retrieve(client, id) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)

          with {:ok, resp} <- request(:get, resource_url, %{}, client) do
            {:ok, to_struct(resp, __MODULE__)}
          end
        end
      end

      if :update in unquote(opts) do
        @doc """
        Update a(n) #{__MODULE__ |> Module.split() |> List.last()}
        """
        @spec update(Client.t(), binary()) :: {:ok, __MODULE__.t()} | {:error, Upvest.error()}
        def update(client, id, data) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:patch, resource_url, data, client)
        end
      end

      if :list in unquote(opts) do
        @doc """
        List specific number of #{__MODULE__ |> Module.split() |> List.last()}
        """
        @spec list_n(Client.t(), non_neg_integer()) ::
                {:ok, [__MODULE__.t()]} | {:error, Upvest.error()}
        def list_n(client, count) do
          do_list_n(endpoint(), count, client, [])
        end

        defp do_list_n(url, count, client, acc) do
          {:ok, resp} = request(:get, url, %{}, client)
          next = Map.get(resp, "next")
          acc = acc ++ resp["results"]

          case is_nil(next) or length(acc) == count do
            true ->
              {:ok, to_struct(acc, __MODULE__)}

            _ ->
              uri = URI.parse(next)
              params = Map.put(URI.decode_query(uri.query), :page_size, @page_size)
              next_url = URI.parse(next).path |> String.slice(4..-1)
              next_url = "#{next_url}?#{URI.encode_query(params)}"
              do_list_n(next_url, count, client, acc)
          end
        end

        @doc """
        List all #{__MODULE__ |> Module.split() |> List.last()}
        """
        @spec list(Client.t()) :: {:ok, [__MODULE__.t()]} | {:error, Upvest.error()}
        def list(client) do
          do_list(endpoint(), client, [])
        end

        defp do_list(url, client, acc) do
          with {:ok, resp} <- request(:get, url, %{page_size: @page_size}, client) do
            next = Map.get(resp, "next")
            acc = acc ++ resp["results"]

            case is_nil(next) do
              true ->
                {:ok, to_struct(acc, __MODULE__)}

              _ ->
                uri = URI.parse(next)
                params = Map.put(URI.decode_query(uri.query), :page_size, @page_size)
                next_url = URI.parse(next).path |> String.slice(4..-1)
                next_url = "#{next_url}?#{URI.encode_query(params)}"
                do_list(next_url, client, acc)
            end
          end
        end
      end

      if :delete in unquote(opts) do
        @doc """
        Delete a(n) #{__MODULE__ |> Module.split() |> List.last()}
        """
        @spec delete(Client.t(), binary()) :: {:ok, nil} | {:error, Upvest.error()}
        def delete(client, id) when is_bitstring(id) do
          resource_url = Path.join(endpoint(), id)
          request(:delete, resource_url, %{}, client)
        end
      end
    end
  end
end
