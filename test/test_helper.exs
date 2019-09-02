ExUnit.start()
Envy.auto_load()

defmodule Upvest.TestHelper do
  alias Upvest.Authentication.{KeyAuth, OAuth}

  def new_test_client(:key) do
    api_key = System.get_env("API_KEY")
    api_secret = System.get_env("API_SECRET")
    api_passphrase = System.get_env("API_PASSPHRASE")

    keyauth = %KeyAuth{api_key: api_key, api_secret: api_secret, api_passphrase: api_passphrase}
    Upvest.Client.new(keyauth)
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

    Upvest.Client.new(oauth)
  end
end
