defmodule Upvest.Tenancy.User do
  use Upvest.API, [:retrieve, :delete, :list]

  def endpoint do
    "/tenancy/users/"
  end

  @spec create(binary, binary, Client.t()) :: Upvest.response()
  def create(username, password, client) do
    params = %{username: username, password: password}
    request(:post, endpoint(), params, client)
  end

  @spec change_password(binary, binary, binary, Client.t()) :: Upvest.response()
  def change_password(username, old_password, new_password, client) do
    params = %{username: username, old_password: old_password, new_password: new_password}
    url = Path.join(endpoint(), username)
    request(:patch, url, params, client)
  end
end
