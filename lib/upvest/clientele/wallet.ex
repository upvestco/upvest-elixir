defmodule Upvest.Clientele.Wallet do
  @moduledoc """
  Handles operations related to Wallet

  You can:
  - Retrieve wallet
  - List all wallets
  - List specific number of wallets

  For more details see `https://doc.upvest.co/reference#kms_wallet_list`
  """
  use Upvest.API, [:list, :retrieve]
  alias Upvest.Clientele.Wallet.Signature

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
  def create(client, password, asset_id, index \\ 0, type \\ :encrypted) do
    params = %{asset_id: asset_id, password: password, index: index, type: type}

    with {:ok, resp} <- request(:post, endpoint(), params, client) do
      {:ok, to_struct(resp, Wallet)}
    end
  end

  @doc """
  Sign (the hash of) data with the private key corresponding to this wallet.
  """
  @spec sign(Client.t(), binary, binary, binary(), binary(), binary()) :: Upvest.response()
  def sign(client, password, wallet_id, to_sign, input_format, output_format) do
    url = "#{endpoint()}#{wallet_id}/sign"

    params = %{
      wallet_id: wallet_id,
      to_sign: to_sign,
      password: password,
      input_format: input_format,
      output_format: output_format
    }

    with {:ok, resp} <- request(:post, url, params, client) do
      {:ok, to_struct(resp, Signature)}
    end
  end
end

defmodule Upvest.Clientele.Wallet.Signature do
  @moduledoc """
  Signature represents the signed wallet signature
  For more details, see `https://doc.upvest.co/reference#kms_sign`
  """

  defstruct [:big_number_format, :algorithm, :curve, :public_key, :r, :s, :recover]
end
