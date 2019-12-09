defmodule Upvest.Tenancy.Historical.HDBlock do
  @moduledoc """
  HDBlock represents block object from historical data API
  """
  defstruct [
    :number,
    :hash,
    :parent_hash,
    :nonce,
    :sha3uncles,
    :transactions_root,
    :receipts_root,
    :miner,
    :difficulty,
    :total_difficulty,
    :extra_data,
    :size,
    :gas_limit,
    :gas_used,
    :transactions,
    :timestamp,
    :uncles
  ]
end

defmodule Upvest.Tenancy.Historical.HDTransaction do
  @moduledoc """
  HDTransaction represents transaction object from historical data API
  """

  defstruct [
    :block_hash,
    :block_number,
    :from,
    :gas,
    :hash,
    :nonce,
    :transaction_index,
    :to,
    :value,
    :gas_price,
    :input,
    :confirmations
  ]
end

defmodule Upvest.Tenancy.Historical.HDBalance do
  @moduledoc """
  HDBalance reprents balance of an asset or contract
  if native asset balance,contract is set to address of the contract
  """

  defstruct [
    :id,
    :address,
    :contract,
    :balance,
    :transaction_hash,
    :transaction_index,
    :block_hash,
    :block_number,
    :timestamp,
    :is_main_chain
  ]
end

defmodule Upvest.Tenancy.Historical.HDTransactionList do
  @moduledoc """
  HDTransactionList is a list of HDTransaction objects
  """
  # result -> [HDTransaction]
  defstruct [:result, :next_cursor]
end

defmodule Upvest.Tenancy.Historical.HDStatus do
  @moduledoc """
  HDStatus represents historical data API status object
  """
  defstruct [:lowest, :highest, :latest]
end

defmodule Upvest.Tenancy.Historical.TxFilters do
  @moduledoc """
  TxFilters is for filtering historical Data API queries
  """
  defstruct [:before, :after, :confirmations, :cursor, :limit]
end


defmodule Upvest.Tenancy.Historical do
  @moduledoc """
  Handles operations related to historical blockchain data.

  You can:
  - Retrieve block details by blockNumber
  - List transactions that have been sent to and received by an address
  - Retrieve transaction (single) by txhash
  - Retrieve native asset balance by address
  - Retrieve contract asset balance by address
  - GET API status
  """
  @type t :: HDTransaction | HDBalance | HDBlock | HDStatus
  
  use Upvest.API, [:dry]
  alias Upvest.Tenancy.Historical.{HDTransaction, HDBalance, HDBlock, HDStatus}
  alias Upvest.Tenancy.Historical.TxFilters
  
  def endpoint do
    "/data"
  end

  @doc "Retrieve block details by block number"
  def get_block(client, protocol, network, block_number) do
    url = "#{endpoint()}/#{protocol}/#{network}/block/#{block_number}"    
    with {:ok, resp} <- request(:get, url, %{}, client) do
      {:ok, to_struct(resp["result"], HDBlock, true)}
    end
  end

  @doc """
  List transactions that have been sent to and received by an address.
  Takes an optional parameter of transaction filters
  """
  def list_transactions(client, protocol, network, address, opts \\ %TxFilters{}) do
    url = "#{endpoint()}/#{protocol}/#{network}/transactions/#{address}"
    opts = Enum.reject(opts, &is_nil/1) |> Enum.into(%{})
    with {:ok, resp} <- request(:get, url, opts, client) do
      {:ok, to_struct(resp["result"], HDTransaction, true)}
    end 
  end

  @doc "Retrieve transaction (single) by txhash"
  def get_transaction(client, protocol, network, txhash) do
    url = "#{endpoint()}/#{protocol}/#{network}/transaction/#{txhash}"
    with {:ok, resp} <- request(:get, url, %{}, client) do
      {:ok, to_struct(resp["result"], HDBalance, true)}
    end
  end

  @doc "Retrieve native asset balance by address"
  def get_balance(client, protocol, network, address) do
    url = "#{endpoint()}/#{protocol}/#{network}/balance/#{address}"
    with {:ok, resp} <- request(:get, url, %{}, client) do
      {:ok, to_struct(resp["result"], HDBalance, true)}
    end
  end
  
  @doc "Retrieve contract asset balance by address"
  def get_balance(client, protocol, network, address, contract_address) do
    url = "#{endpoint()}/#{protocol}/#{network}/balance/#{address}/#{contract_address}"
    with {:ok, resp} <- request(:get, url, %{}, client) do
      {:ok, to_struct(resp["result"], HDBalance, true)}
    end
  end
  
  def api_status(client, protocol, network) do
    url = "#{endpoint()}/#{protocol}/#{network}"
    with {:ok, resp} <- request(:get, url, %{}, client) do
      {:ok, to_struct(resp["result"], HDStatus)}
    end
  end
end
