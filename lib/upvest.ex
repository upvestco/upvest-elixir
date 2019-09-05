defmodule Upvest do
  @moduledoc """
  Documentation for Upvest.
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
    # {"Content-Type", "application/json"},
    {"Accept", "application/json"}
  ]

  @type error ::
          APIError.t()
          | APIConnectionError.t()
          | AuthenticationError.t()
          | InvalidRequestError.t()
          | PermissionError.t()
  # TODO (yao): define more specific response type
  @type response :: {:ok, any()} | {:error, error}

  def version do
    @client_version
  end

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

  # delete endpoint returns 204 No Content 
  defp handle_response({:ok, %{status_code: 204}}) do
    {:ok, nil}
  end

  defp handle_response({:ok, %{body: body, status_code: code}}) when code in [200, 201] do
    {:ok, parse_response_body(body)}
  end

  defp handle_response({:ok, %{body: body, status_code: code}} = _req) do
    response = Map.get(parse_response_body(body), "error")
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
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    %APIConnectionError{message: "Network Error: #{reason}"}
  end

  defp parse_response_body(body) do
    Poison.decode!(body)
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
