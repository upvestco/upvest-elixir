defmodule Upvest.Clientele.Wallet do
  use Upvest.API, [:list, :retrieve]

  defstruct [:address, :balances, :id, :index, :protocol, :status]

  def endpoint do
    "/kms/wallets/"
  end

  @doc """
  Create a new wallet.

  The password is necessary to decrypt the Seed data to create the private key for the new wallet, 
  and then to encrypt the new private key.
  """
  @spec create(Client.t(), binary, binary, non_neg_integer(), atom()) :: Upvest.response()
  def create(client, asset_id, password, index \\ 0, type \\ :encrypted) do
    params = %{asset_id: asset_id, password: password, index: index, type: type}
    request(:post, endpoint(), params, client)
  end

  @doc """
  Sign (the hash of) data with the private key corresponding to this wallet.
  """
  @spec sign(Client.t(), binary, binary, binary(), binary(), binary()) :: Upvest.response()
  def sign(client, wallet_id, to_sign, password, input_format, output_format) do
    url = "#{endpoint()}#{wallet_id}/sign"

    params = %{
      wallet_id: wallet_id,
      to_sign: to_sign,
      password: password,
      input_format: input_format,
      output_format: output_format
    }

    request(:post, url, params, client)
  end
end
