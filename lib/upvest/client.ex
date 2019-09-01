defmodule Upvest.Client do
  # TODO: support user config of the timeout and underlying http client
  alias Upvest.Authentication.{KeyAuth, OAuth}
  alias __MODULE__

  # API version is the currently supported API version
  @api_version "1.0"

  # http timeout is the default timeout on the http client
  @http_timeout 60
  # base_url for all requests. default to playground environment
  @base_url "https://api.playground.upvest.co/"

  defstruct auth: nil, base_url: @base_url, headers: %{}

  @type auth :: KeyAuth.t() | OAuth.t()
  @type t :: %__MODULE__{auth: auth | nil, base_url: binary, headers: map()}

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

  @spec url(client :: Client.t(), path :: binary) :: binary
  def url(_client = %Client{base_url: base_url}, path) do
    Path.join(base_url, versioned_url(path)) <> "/"
  end

  @spec versioned_url(path :: binary) :: binary
  def versioned_url(path) do
    Path.join(@api_version, path) <> "/"
  end
end
