defmodule Upvest.Tenancy.User do
  use Upvest.API, [:retrieve, :get, :update, :delete, :list]

  def endpoint do
    "/tenancy/users/"
  end

  @spec create(binary, binary, Client.t) :: {:ok, map} | {:error, map}
  def create(username, password, client) do
    params = %{username: username, password: password}
    request(:post, endpoint(), params, client)
  end
end
