defmodule Upvest.Tenancy.Asset do
  @moduledoc """
  Handles operations related to Assets.

  You can:
  - List all assets
  - List specific number of assets

  For more details see `https://doc.upvest.co/reference#assets`
  """
  use Upvest.API, [:list, :retrieve]

  defstruct [:id, :name, :symbol, :exponent, :protocol, :metadata]

  def endpoint do
    "/assets/"
  end
end
