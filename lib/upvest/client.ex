defmodule Upvest.Client do
  # TODO: support user config of the timeout and underlying http client
  alias Upvest.Authentication.{KeyAuth, OAuth}
  alias __MODULE__
  alias Upvest.Utils

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

  @spec new() :: t
  def new(), do: %__MODULE__{}

  @spec new(auth) :: t
  def new(auth) do
    pnew(auth, @base_url)
  end

  @spec new(map(), binary) :: t
  def new(auth = %KeyAuth{}, base_url) do
    pnew(auth, base_url)
  end

  @spec new(map(), binary) :: t
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
    # missing trailing slash results in 404 on some urls, /tenancy/users
    path1 = Path.join(@api_version, path)
    if String.ends_with?(path, "/"), do: path1 <> "/", else: path1
  end
end
