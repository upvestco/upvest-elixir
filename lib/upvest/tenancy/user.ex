defmodule Upvest.Tenancy.User do
  @moduledoc """
  Handles operations related to the user

  You can:
  - Create a user
  - Retrieve a user
  - Change user password
  - List all users
  - List specific number of users
  - Delete a user

  For more details see `https://doc.upvest.co/reference#tenancy_user_list`
  """
  use Upvest.API, [:retrieve, :delete, :all, :list]

  defstruct [:username, :recoverykit, :wallets]

  def endpoint do
    "/tenancy/users/"
  end

  @doc """
  Create a user.

  For more details `https://doc.upvest.co/reference#tenancy_user_create`
  """
  @spec create(Client.t(), binary, binary) :: {:ok, t} | {:error, Upvest.error()}
  def create(client, username, password) do
    params = %{username: username, password: password}

    with {:ok, user} <- request(:post, endpoint(), params, client) do
      {:ok, to_struct(user, User)}
    end
  end

  @doc """
  Change password for a user

  For more details see `https://doc.upvest.co/reference#tenancy_user_password_update`
  """
  @spec change_password(Client.t(), binary, binary, binary) :: {:ok, t} | {:error, Upvest.error()}
  def change_password(client, username, old_password, new_password) do
    params = %{username: username, old_password: old_password, new_password: new_password}
    url = Path.join(endpoint(), username)

    with {:ok, user} <- request(:patch, url, params, client) do
      {:ok, to_struct(user, User)}
    end
  end
end
