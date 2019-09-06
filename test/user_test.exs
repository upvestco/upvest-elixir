defmodule Upvest.UsersTest do
  use ExUnit.Case, async: false
  alias Upvest.Tenancy.User
  import Upvest.TestHelper
  import Upvest.Utils, only: [timestamp: 0]

  doctest Upvest.Tenancy.User

  @client new_test_client(:key)

  setup_all do
    ts = timestamp()
    {:ok, user} = User.create(@client, "upvest_user_#{ts}", "#{ts}")

    on_exit(fn -> User.delete(@client, user.username) end)

    {:ok, [user: user, password: ts]}
  end

  test "list all users", _context do
    {:ok, users} = User.list(@client)
    assert is_list(users)
    assert Enum.random(users).__struct__ == User
  end

  test "list subset of  users", _context do
    {:ok, users} = User.list_n(@client, 210)
    assert is_list(users)
    assert Enum.random(users).__struct__ == User
  end

  test "change password", context do
    {:ok, user} =
      User.change_password(@client, context.user.username, context.password, timestamp())

    assert user.username == context.user.username
  end
end
