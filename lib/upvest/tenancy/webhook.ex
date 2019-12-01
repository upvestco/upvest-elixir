defmodule Upvest.Tenancy.Webhook do
  @moduledoc """
  Handles operations related to Webhooks.

  You can:
  - Create a webhook
  - Retrieve an webhook
  - Delete a webhook
  - Verify a webhook
  - List all webhooks
  - List specific number of webhooks
  """
  use Upvest.API, [:retrieve, :delete, :list, :all] 

  defstruct [:id, :url, :name, :hmac_secret_key, :headers, :version, :status, :event_filters]

  def endpoint do
    "/tenancy/webhooks/"
  end

  @doc """
  Create a new webhook.
  """
  @spec create(Client.t(), t()) :: Upvest.response()
  def create(client, webhook) do
    with {:ok, resp} <- request(:post, endpoint(), webhook, client) do
      {:ok, to_struct(resp, Webhook)}
    end
  end

  @doc """
  Verify and confirm the webhook notification endpoint
  """
  @spec verify(Client.t(), binary) :: Upvest.response()
  def verify(client, verify_url) do
    url = "/tenancy/webhooks-verify/"
    params = %{verify_url: verify_url}
    # TODO: confirm verify endpoint response
    request(:post, url, params, client)
  end
end
