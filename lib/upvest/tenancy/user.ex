defmodule Upvest.Tenancy.User do
  use Upvest.API, [:retrieve, :delete, :list]

  def endpoint do
    "/tenancy/users/"
  end

  @spec create(Client.t(), binary, binary) :: Upvest.response()
  def create(client, username, password) do
    params = %{username: username, password: password}
    request(:post, endpoint(), params, client)
  end

  @spec change_password(Client.t(), binary, binary, binary) :: Upvest.response()
  def change_password(client, username, old_password, new_password) do
    params = %{username: username, old_password: old_password, new_password: new_password}
    url = Path.join(endpoint(), username)
    request(:patch, url, params, client)
  end
end
