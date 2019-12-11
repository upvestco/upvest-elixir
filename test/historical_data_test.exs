defmodule Upvest.HistoricalDataTest do
  use ExUnit.Case, async: false
  alias Upvest.Tenancy.Historical
  alias Upvest.Tenancy.Historical.{HDTransaction, HDBalance, HDBlock, HDStatus}
  import Upvest.TestHelper

  doctest Upvest.Tenancy.Historical

  @client new_tenancy_client()
  @protocol "ethereum"
  @network "ropsten"
  
  test "retrieve block details by block number" do
    block_number = "6570890"
    {:ok, block} = Historical.get_block(@client, @protocol, @network, block_number)    
    assert block.number == block_number
  end

  test "get transactions by txhash" do
    txhash = "0xa313aaad0b9b1fd356f7f42ccff1fa385a2f7c2585e0cf1e0fb6814d8bdb559a"
    {:ok, tx} = Historical.get_transaction(@client, @protocol, @network, txhash)
    assert tx.hash == String.slice(txhash, 2..-1)
  end
  
  test "get transactions to/from address" do
    to_addr = "0x6590896988376a90326cb2f741cb4f8ace1882d5"
    {:ok, tx} = Historical.all_transactions(@client, @protocol, @network, to_addr)
    assert is_list(tx.result)
  end

  test "get asset balance" do
    to_addr = "0x93b3d0b2894e99c2934bed8586ea4e2b94ce6bfd"
    {:ok, balance} = Historical.get_balance(@client, @protocol, @network, to_addr)
    assert balance.address
    assert balance.contract == nil
    assert balance.address == to_addr
  end

  test "get contract balance" do
    to_addr = "0x93b3d0b2894e99c2934bed8586ea4e2b94ce6bfd"
    contract_addr = "0x1d7cf6ad190772cc6177beea2e3ae24cc89b2a10"
    {:ok, balance} = Historical.get_balance(@client, @protocol, @network, to_addr, contract_addr)
    assert balance.address
    assert balance.contract == contract_addr
    assert balance.address == to_addr
  end

  test "get status" do
    {:ok, status} = Historical.api_status(@client, @protocol, @network)
    assert Enum.all?([status.lowest, status.highest, status.latest])
  end    
end
