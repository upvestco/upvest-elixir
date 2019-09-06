defmodule Upvest.Tenancy.Asset do
  use Upvest.API, [:list, :retrieve]

  defstruct [:id, :name, :symbol, :exponent, :protocol, :metadata]

  def endpoint do
    "/assets/"
  end
end
