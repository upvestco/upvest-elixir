defmodule Upvest.UsersTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Upvest.Tenancy.User
  import Upvest.TestHelper

  doctest Upvest.Tenancy.User

  @client new_test_client(:key)

  setup_all do
    HTTPoison.start()
  end

  test "list all users" do
    use_cassette "user#list_all", match_requests_on: [:query] do
      {:ok, resp} = list(@client)
    end
  end
end
