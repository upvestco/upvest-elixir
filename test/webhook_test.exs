defmodule Upvest.WebhookTest do
  use ExUnit.Case, async: false
  alias Upvest.Tenancy.Webhook
  import Upvest.TestHelper

  doctest Upvest.Tenancy.Webhook

  @client new_tenancy_client()
  
  @webhook_url System.get_env("WEBHOOK_URL")
  @webhook_verification_url System.get_env("WEBHOOK_VERIFICATION_URL")

  @webhook %Webhook{
    url: @webhook_url,
    name: "test-webhook-#{}",
    headers: %{"X-Test": "Hello world!"},
    version: "1.2",
    status: "ACTIVE",
    event_filters: ["upvest.wallet.created", "ropsten.block.*", "upvest.echo.post"],
    hmac_secret_key: "abcdef"
  }

  test "get all webhooks" do
    {:ok, webhooks} = Webhook.all(@client)    
    assert Enum.all?(webhooks, fn x -> x.__struct__ == Webhook end)
  end

  test "verify webhook" do
    Webhook.verify(@client, @webhook_verification_url)
  end
  
  test "create, retrieve and delete webhook" do
    with {:ok, webhook} <- Webhook.create(@client, @webhook),
         # pattern match with created with retrieved
         {:ok, webhook} <- Webhook.retrieve(@client, webhook.id) do
      # now delete webhook
      Webhook.delete(@client, webhook.id)
    end
  end
  
end
