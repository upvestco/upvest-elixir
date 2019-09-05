defmodule Upvest.UsersTest do
  use ExUnit.Case, async: false
  alias Upvest.Tenancy.User
  import Upvest.TestHelper
  import Upvest.Utils, only: [timestamp: 0]

  doctest Upvest.Tenancy.User

  @client new_test_client(:key)

  setup_all do
    ts = timestamp()
    {:ok, user} = User.create("upvest_user_#{ts}", "#{ts}", @client)

    on_exit(fn ->
      IO.puts("Cleaning up setup data for user test")
      User.delete(user["username"], @client)
    end)

    {:ok, [user: user, password: ts]}
  end

  test "list all users", _context do
    {:ok, users} = User.list(@client)
    assert is_list(users)
    assert length(users) > 300
    # test all objects have the same keys
    object_keys = Enum.reduce(users, [], &(Map.keys(&1) ++ &2)) |> Enum.uniq()
    assert object_keys == ["username", "wallets"]
  end

  test "list subset of  users", _context do
    {:ok, users} = User.list_n(210, @client)
    assert is_list(users)
    assert length(users) == 210
    # test all objects have the same keys
    object_keys = Enum.reduce(users, [], &(Map.keys(&1) ++ &2)) |> Enum.uniq()
    assert object_keys == ["username", "wallets"]
  end

  test "change password", context do
    {:ok, user} =
      User.change_password(context.user["username"], context.password, timestamp(), @client)

    assert user["username"] == context.user["username"]
  end
end
