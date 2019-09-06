defmodule Upvest.WalletTest do
  use ExUnit.Case, async: false
  alias Upvest.Clientele.Wallet
  alias Upvest.Clientele.Wallet.Signature
  alias Upvest.Tenancy.Asset
  import Upvest.TestHelper

  doctest Upvest.Clientele.Wallet

  @client new_test_client(:oauth)

  @user_password System.get_env("UPVEST_TEST_PASSWORD")

  @eth_wallet %Wallet{
    id: "8fc19cd0-8f50-4626-becb-c9e284d2315b",
    balances: [
      %{
        amount: 0,
        asset_id: "cfc59efb-3b21-5340-ae96-8cadb4ce31a8",
        name: "Example coin",
        symbol: "COIN",
        exponent: 12
      }
    ],
    protocol: "ethereum_ropsten",
    address: "0xc4a284e55ab2f1c2feb23a0bfc56fca31b0c94a3",
    status: "ACTIVE",
    index: 0
  }

  setup_all do
    asset_id = Enum.at(@eth_wallet.balances, 0).asset_id
    {:ok, wallet} = Wallet.create(@client, asset_id, @user_password)

    {:ok, [wallet: wallet]}
  end

  test "list all wallets" do
    {:ok, wallets} = Wallet.list(@client)
    assert is_list(wallets)
    assert Enum.random(wallets).__struct__ == Wallet
  end

  test "list specific number of wallets" do
    {:ok, wallets} = Wallet.list_n(@client, 210)
    assert is_list(wallets)
    assert Enum.random(wallets).__struct__ == Wallet
  end

  test "sign wallet", context do
    to_sign = random_string() |> Base.encode16(case: :lower)
    {:ok, resp} = Wallet.sign(@client, context.wallet.id, to_sign, @user_password, "hex", "hex")
    assert resp.__struct__ == Signature
  end

  test "retrieve wallet", context do
    {:ok, wallet} = Wallet.retrieve(@client, context.wallet.id)
    assert wallet.__struct__ == Wallet

    assert context.wallet.id == wallet.id
  end
end
