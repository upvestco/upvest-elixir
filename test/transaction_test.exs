defmodule Upvest.TransactionTest do
  use ExUnit.Case, async: false
  alias Upvest.Clientele.{Wallet, Transaction}
  import Upvest.TestHelper

  doctest Upvest.Clientele.Transaction

  @client new_test_client(:oauth)

  @user_password System.get_env("UPVEST_TEST_PASSWORD")

  @eth_wallet %Wallet{
    id: "8fc19cd0-8f50-4626-becb-c9e284d2315b",
    balances: [],
    protocol: "ethereum_ropsten",
    address: "0xc4a284e55ab2f1c2feb23a0bfc56fca31b0c94a3",
    status: "ACTIVE",
    index: 0
  }

  @eth_ropsten_asset_id "deaaa6bf-d944-57fa-8ec4-2dd45d1f5d3f"

  setup_all do
    quantity = 10_000_000_000_000_000
    fee = 41_180_000_000_000
    recipient = "0xf9b44Ba370CAfc6a7AF77D0BDB0d50106823D91b"

    {:ok, transaction} =
      Transaction.create(
        @client,
        @user_password,
        @eth_wallet.id,
        @eth_ropsten_asset_id,
        quantity,
        fee,
        recipient
      )

    {:ok, [transaction: transaction]}
  end

  test "list all transactions" do
    {:ok, transactions} = Transaction.list(@client)
    assert is_list(transactions)
    assert Enum.random(transactions).__struct__ == Transaction
  end

  test "list specific number of transactions" do
    {:ok, transactions} = Transaction.list_n(@client, 210)
    assert is_list(transactions)
    assert Enum.random(transactions).__struct__ == Transaction
  end

  test "retrieve transaction", context do
    {:ok, transaction} = Transaction.retrieve(@client, context.transaction.id)
    assert transaction.__struct__ == Transaction

    assert context.transaction.id == transaction.id
  end
end
