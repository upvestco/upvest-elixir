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
    {"Content-Type", "application/json"},
    {"Accept", "application/json"}
  ]

  def version do
    @client_version
  end

  defp get_headers(client, action, endpoint, data) do
    AuthProvider.get_headers(client.auth, action, endpoint, data)
    |> Map.merge(Map.new(@base_headers))
    |> Map.merge(client.headers)
  end

  def request(action, endpoint, data, client) do
    url = Client.url(client, endpoint)
    headers = get_headers(client, action, endpoint, data)

    HTTPoison.request(action, url, Poison.encode!(data), headers)
    |> handle_response
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
