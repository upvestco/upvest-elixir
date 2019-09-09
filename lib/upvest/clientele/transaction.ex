defmodule Upvest.Clientele.Transaction do
  @moduledoc """
  Handles operations related to user transactions

  You can:
  - Create new transaction
  - List all transactions
  - List specific number of transactions

  For more details see `https://doc.upvest.co/reference#kms_transaction_list`
  """
  use Upvest.API, [:list, :retrieve]

  defstruct [:address, :balances, :id, :index, :protocol, :status]

  def endpoint do
    "/kms/wallets/~s/transactions/"
  end

  @spec create(
          Client.t(),
          binary(),
          binary(),
          binary(),
          non_neg_integer(),
          non_neg_integer(),
          binary()
        ) :: {:ok, Transaction.t()} | {:error, Upvest.error()}
  def create(client, password, wallet_id, asset_id, quantity, fee, recipient) do
    params = %{
      wallet_id: wallet_id,
      password: password,
      asset_id: asset_id,
      quantity: quantity,
      fee: fee,
      recipient: recipient
    }

    url = sprintf(endpoint(), [wallet_id])

    with {:ok, resp} <- request(:post, url, params, client) do
      {:ok, to_struct(resp, Transaction)}
    end
  end
end
