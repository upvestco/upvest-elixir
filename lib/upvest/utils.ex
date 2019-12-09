defmodule Upvest.Utils do
  @moduledoc """
  Utility functions for Upvest
  """

  @doc """
  Returns current timestamp in seconds
  """
  def timestamp do
    :os.system_time(:seconds)
  end

  @doc """
  Creates a struct from the given struct module and data

  Intended for transforming raw data received from Upvest to a struct.

  ## Examples

  iex> data = %{
  ...>  exponent: 12,
  ...>  id: "51bfa4b5-6499-5fe2-998b-5fb3c9403ac7",
  ...>  metadata: %{
  ...>    "genesis" => "AX7fqNywVSYFBjqMiAApi1KOjAz-7JvMoFXAewyabWD1Jk2KdzFroYsqUpxSa0hh"
  ...>  },
  ...>  name: "Arweave (internal testnet)",
  ...>  protocol: "arweave_testnet",
  ...>  symbol: "AR"
  ...>  }
  ...> to_struct([asset], Upvest.Tenancy.Asset)
  %Upvest.Tenancy.Asset{
    exponent: 12,
    id: "51bfa4b5-6499-5fe2-998b-5fb3c9403ac7",
    metadata: %{
      "genesis" => "AX7fqNywVSYFBjqMiAApi1KOjAz-7JvMoFXAewyabWD1Jk2KdzFroYsqUpxSa0hh"
    },
    name: "Arweave (internal testnet)",
    protocol: "arweave_testnet",
    symbol: "AR"
  }
  """
  @spec to_struct(Enum.t(), struct(), boolean) :: struct()
  def to_struct(data, module, camel \\ false) do
    if is_list(data) do
      Enum.map(data, &transform(&1, module, camel))
    else
      transform(data, module, camel)
    end
  end

  def transform(data, module, camel \\ false) do
    struct = struct(module)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(data, camelize(k, camel)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  defp camelize(key, false), do: "#{key}"
  defp camelize(key, _), do: Macro.camelize("#{key}")
  
  @doc """
  Formats according the given string format specifier and returns the resulting string.
  The params argument needs to be List.

  ## Examples

  iex> sprintf("/foo/~r/bar", "hi")
  ...> /foo/hi/bar
  """
  @spec sprintf(binary(), list(any())) :: binary()
  def sprintf(format, params) do
    :io_lib.format(format, params) |> to_string
  end
end
