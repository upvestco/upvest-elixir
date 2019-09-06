defprotocol Upvest.AuthProvider do
  @moduledoc """
  AuthProvider desfines a behaviour for authentication mechanisms supported by Upvest API

  # TODO: define custom type for headers and possible erorr types
  """

  @doc """
  Verifies the given authentication parameters and returns authorization
  headers (or other info) to be attached to requests.
  """
  @spec get_headers(
          auth :: Upvest.Client.auth(),
          method :: String.t(),
          path :: String.t(),
          body :: map()
        ) :: {:ok, map()} | {:error, String.t()}
  def get_headers(auth, method, path, body)
end

defmodule Upvest.Authentication.KeyAuth do
  defstruct [:api_key, :api_secret, :api_passphrase]
end

defimpl Upvest.AuthProvider, for: Upvest.Authentication.KeyAuth do
  @moduledoc """
  Authenticates requests on tenant endpoints using API keys.
  """
  alias Upvest.Client
  import Upvest.Utils, only: [timestamp: 0]

  def get_headers(auth, method, path, body) do
    versioned_path = Client.versioned_url(path)
    ts = timestamp()
    message = "#{ts}#{String.upcase(to_string(method))}#{versioned_path}#{Poison.encode!(body)}"

    %{
      "Content-Type": "application/json",
      "X-UP-API-Key": auth.api_key,
      "X-UP-API-Signature": generate_signature(message, auth.api_secret),
      "X-UP-API-Timestamp": ts,
      "X-UP-API-Passphrase": auth.api_passphrase,
      "X-UP-API-Signed-Path": versioned_path
    }
  end

  defp generate_signature(message, api_secret) do
    :crypto.hmac(:sha512, api_secret, message) |> Base.encode16(case: :lower)
  end
end

defmodule Upvest.Authentication.OAuth do
  defstruct [:client_id, :client_secret, :username, :password]
end

defimpl Upvest.AuthProvider, for: Upvest.Authentication.OAuth do
  alias Upvest.Client
  import Upvest, only: [request: 4]

  # urlencodeheader is the content-type header for OuAth2
  @urlencodeheader "application/x-www-form-urlencoded"
  @oauth_path "/clientele/oauth2/token"
  @grant_type "password"
  @scope "read write echo transaction"

  def get_headers(auth, _method, _path, _body) do
    access_token = get_access_token(auth)

    # Retrieve and return OAuth token
    %{
      Authorization: "Bearer #{access_token}",
      "Content-Type": "application/json"
    }
  end

  defp get_access_token(auth) do
    params = %{
      grant_type: @grant_type,
      scope: @scope,
      client_id: auth.client_id,
      client_secret: auth.client_secret,
      username: auth.username,
      password: auth.password
    }

    headers = %{
      "Content-Type": @urlencodeheader,
      "Cache-Control": "no-cache"
    }

    {:ok, resp} = request(:post, @oauth_path, params, %{Client.new() | headers: headers})
    resp["access_token"]
  end
end
