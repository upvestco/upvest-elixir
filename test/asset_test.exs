defmodule Upvest.AssetTest do
  use ExUnit.Case, async: false
  alias Upvest.Tenancy.Asset
  import Upvest.TestHelper

  doctest Upvest.Tenancy.Asset

  @client new_test_client(:key)

  @arweave_asset %Asset{
    exponent: 12,
    id: "51bfa4b5-6499-5fe2-998b-5fb3c9403ac7",
    metadata: %{
      "genesis" => "AX7fqNywVSYFBjqMiAApi1KOjAz-7JvMoFXAewyabWD1Jk2KdzFroYsqUpxSa0hh"
    },
    name: "Arweave (internal testnet)",
    protocol: "arweave_testnet",
    symbol: "AR"
  }

  test "get all assets" do
    {:ok, assets} = Asset.all(@client)
    assert Enum.random(assets).__struct__ == Asset
  end

  test "retrieve AR Weave asset" do
    {:ok, asset} = Asset.retrieve(@client, @arweave_asset.id)

    assert @arweave_asset == asset
  end
end
