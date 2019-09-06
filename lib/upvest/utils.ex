defmodule Upvest.Utils do
  def timestamp do
    :os.system_time(:seconds)
  end

  @doc """
  Creates a struct from the given struct module and data
  """
  @spec to_struct(list() | Enum.t(), module() | struct()) :: struct()
  def to_struct(data, module) when is_list(data) do
    Enum.map(data, &to_struct(&1, module))
  end

  def to_struct(data, module) do
    struct = struct(module)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(data, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  @doc """
  Formats according the given string format specifier and returns the resulting string.
  The params argument needs to be List.
  """
  @spec sprintf(binary(), list(any())) :: binary()
  def sprintf(format, params) do
    :io_lib.format(format, params) |> to_string
  end
end
