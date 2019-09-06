defmodule Upvest.Tenancy.Asset do
  use Upvest.API, [:list, :retrieve]

  def endpoint do
    "/assets/"
  end
end
