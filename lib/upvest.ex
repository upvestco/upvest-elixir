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

  def request(action, endpoint, data, client) do
    headers = get_headers(client, action, endpoint, data)
    request_url = url(action, endpoint, data, client)

    HTTPoison.request(action, request_url, encode_body(data, client.headers), headers)
    |> handle_response
  end

  defp encode_body(data, %{"Content-Type": "application/x-www-form-urlencoded"}) do
    URI.encode_query(data)
  end

  defp encode_body(data, _) do
    Poison.encode!(data)
  end

  defp url(_action, endpoint, _data, client) do
    Client.build_url(client, endpoint)
  end

  # TODO: add headers to error
  defp handle_response({:ok, %{body: body, status_code: code, headers: _headers}})
       when code in [200, 201] do
    {:ok, parse_response_body(body)}
  end

  defp handle_response({:ok, %{body: body, status_code: code, headers: _headers}} = _req) do
    response = parse_response_body(body)
    message = Map.get(response, "error")
    errors = Map.get(response, "errors")

    error_struct =
      case code do
        code when code in [400, 422, 404] ->
          %InvalidRequestError{errors: errors, code: code}

        401 ->
          %AuthenticationError{errors: errors}

        403 ->
          %PermissionError{message: message}

        _ ->
          %APIError{message: message}
      end

    {:error, %{error_struct | code: code, message: message}}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    %APIConnectionError{message: "Network Error: #{reason}"}
  end

  defp parse_response_body(body) do
    Poison.decode!(body)
  end
end
