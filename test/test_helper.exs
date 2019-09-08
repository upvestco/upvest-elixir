HTTPoison.start()
ExUnit.start()

defmodule Upvest.TestHelper do
  alias Upvest.Client
  alias Upvest.Authentication.{KeyAuth, OAuth}

  def random_string(length \\ 32) do
    characters = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)

    Enum.map(1..length, fn _ -> Enum.random(characters) end)
    |> to_string
  end

  def new_test_client(:key) do
    api_key = System.get_env("API_KEY")
    api_secret = System.get_env("API_SECRET")
    api_passphrase = System.get_env("API_PASSPHRASE")

    keyauth = %KeyAuth{api_key: api_key, api_secret: api_secret, api_passphrase: api_passphrase}
    Client.new(keyauth)
  end

  def new_test_client(:oauth) do
    client_id = System.get_env("OAUTH2_CLIENT_ID")
    client_secret = System.get_env("OAUTH2_CLIENT_SECRET")
    username = System.get_env("UPVEST_TEST_USERNAME")
    password = System.get_env("UPVEST_TEST_PASSWORD")

    oauth = %OAuth{
      client_id: client_id,
      client_secret: client_secret,
      username: username,
      password: password
    }

    Client.new(oauth)
  end
end
