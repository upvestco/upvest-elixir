defmodule Upvest do
  @moduledoc """
  An HTTP client for Upvest.

  All tenancy related operations must be authenticated using the API Keys Authentication, whereas all actions on a 
  user's behalf need to be authenticated via OAuth. The API calls are built along with those two authentication objects.

  All API calls return either `{:ok, response}` or `{:error, error}`, and where possible succesful 
  response are transformed into Elixir structs mapped to the corresponding Upvest API resource.
  """
  alias Upvest.{
    APIConnectionError,
    AuthenticationError,
    InvalidRequestError,
    PermissionError,
    APIError
  }

  alias Upvest.{Client, AuthProvider}
  @client_version Mix.Project.config()[:version]
  # user agent used when communicating with the Upvest API.
  @useragent "upvest-elixir/#{@client_version}"

  @base_headers [
    {"User-Agent", @useragent},
    {"Content-Type", "application/json; charset=utf8"},
    {"Accept", "application/json"}
  ]

  @type error ::
          APIError.t()
          | APIConnectionError.t()
          | AuthenticationError.t()
          | InvalidRequestError.t()
          | PermissionError.t()

  @type response :: {:ok, any()} | {:ok, binary()} | {:error, error}
  @type http_method :: :get | :post | :patch | :delete
  @type headers :: map()

  @doc """
  Returns the current version of the library
  """
  def version do
    @client_version
  end

  @doc """
  Executes the request and returns the response.
  """
  @spec request(http_method(), binary(), map(), Client.t()) :: response()
  def request(action, endpoint, data, client) do
    headers = get_headers(client, action, endpoint, data)
    request_url = Client.build_url(client, endpoint)

    # timeout here is connection timeout
    # actual http response waiting timeout is recv_timeout
    options = [timeout: 50_000, recv_timeout: client.timeout]
    body = encode_body(data, client.headers)

    HTTPoison.request(action, request_url, body, headers, options)
    |> handle_response
  end

  ## PRIVATE

  # delete endpoint returns 204 No Content 
  defp handle_response({:ok, %{status_code: 204}}) do
    {:ok, nil}
  end

  defp handle_response({:ok, %{body: body, status_code: code}}) when code in [200, 201] do
    parse_response_body(body)
  end

  defp handle_response({:ok, %{body: body, status_code: code}} = _req) do
    # some error such as 404 are plaintext
    with {:ok, body} <- parse_response_body(body) do
      response = Map.get(body, "error", %{})
      message = Map.get(response, "message")
      details = Map.get(response, "details")

      error_struct =
        case code do
          code when code in [400, 422, 404] ->
            %InvalidRequestError{}

          401 ->
            %AuthenticationError{}

          403 ->
            %PermissionError{}

          _ ->
            %APIError{}
        end

      {:error, %{error_struct | code: code, message: message, details: details}}
    else
      {:error, _error} ->
        {:error, %APIError{message: body}}
    end
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    %APIConnectionError{message: "Network Error: #{reason}"}
  end

  defp parse_response_body(body) do
    Poison.decode(body)
  end

  defp get_headers(client = %Client{auth: auth}, action, endpoint, data) do
    cond do
      is_nil(client.auth) ->
        Map.new(@base_headers) |> Map.merge(client.headers)

      true ->
        AuthProvider.get_headers(auth, action, endpoint, data)
        |> Map.merge(Map.new(@base_headers))
        |> Map.merge(client.headers)
    end
  end

  defp encode_body(data, %{"Content-Type": "application/x-www-form-urlencoded"}) do
    URI.encode_query(data)
  end

  defp encode_body(data, _) do
    Poison.encode!(data)
  end
end
