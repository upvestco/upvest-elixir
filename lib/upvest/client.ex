defmodule Upvest.Client do
  @moduledoc """
  A module for composing authentication and request parameters to the Upvest API.

  Currently encompasses key authentication and OAuth authenticationrequired for Tenancy and CLientele 
  APIs respetively. Generally intended to passed in as parameter to Upvest.request/4.

  It's implemented such that you can change the authentication parameter and retain the 
  other configs for requests to other APIs. At a minimum, the authentication config must be present

  The default `BASE_URL` for both authentication objects is `https://api.playground.upvest.co`, 
  but feel free to adjust it, in addition to additional parameters such as extra HTTP headers 
  and http timeout on the client struct.
  """
  alias Upvest.Authentication.{KeyAuth, OAuth}
  alias __MODULE__

  # API version is the currently supported API version
  @api_version "1.0"

  # http timeout is the default timeout on the http client
  @http_timeout 50_000

  # base_url for all requests. default to playground environment
  @base_url "https://api.playground.upvest.co/"

  defstruct auth: nil, base_url: @base_url, headers: %{}, timeout: @http_timeout

  @type auth :: KeyAuth.t() | OAuth.t()
  @type t :: %__MODULE__{
          auth: auth | nil,
          base_url: binary,
          headers: map(),
          timeout: non_neg_integer()
        }

  @doc """
  Returns a new client
  """
  @spec new() :: t
  def new(), do: %__MODULE__{}

  @doc """
  Returns a new client with the given authentication
  """
  @spec new(auth) :: t
  def new(auth) do
    pnew(auth, @base_url)
  end

  @doc """
  Returns a new client with the given authentication and base url
  """
  @spec new(auth(), binary) :: t
  def new(auth = %KeyAuth{}, base_url) do
    pnew(auth, base_url)
  end

  @spec new(auth(), binary) :: t
  def new(auth = %OAuth{}, base_url) do
    pnew(auth, base_url)
  end

  @spec new(auth, binary) :: t
  defp pnew(auth, base_url) do
    %__MODULE__{auth: auth, base_url: base_url}
  end

  @spec build_url(Client.t(), binary) :: binary
  def build_url(_client = %Client{base_url: base_url}, path) do
    URI.merge(URI.parse(base_url), versioned_url(path))
  end

  # @spec build_url(Client.t(), binary, map) :: binary
  # def build_url(_client = %Client{base_url: base_url}, path, params) do
  #   query_params = URI.encode_query(params)
  #   url = URI.merge(URI.parse(base_url), versioned_url(path))
  #   "#{url}?#{query_params}"
  # end

  @spec versioned_url(path :: binary) :: binary
  def versioned_url(path) do
    path1 = Path.join(@api_version, path)
    if String.ends_with?(path, "/"), do: path1 <> "/", else: path1
  end
end
