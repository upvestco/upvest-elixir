defmodule Upvest.Tenancy.User do
  use Upvest.API, [:retrieve, :delete, :list]

  defstruct [:username, :recoverykit, :wallets]

  def endpoint do
    "/tenancy/users/"
  end

  @spec create(Client.t(), binary, binary) :: Upvest.response()
  def create(client, username, password) do
    params = %{username: username, password: password}

    with {:ok, user} <- request(:post, endpoint(), params, client) do
      {:ok, to_struct(user, __MODULE__)}
    end
  end

  @spec change_password(Client.t(), binary, binary, binary) :: Upvest.response()
  def change_password(client, username, old_password, new_password) do
    params = %{username: username, old_password: old_password, new_password: new_password}
    url = Path.join(endpoint(), username)

    with {:ok, user} <- request(:patch, url, params, client) do
      {:ok, to_struct(user, __MODULE__)}
    end
  end
end
