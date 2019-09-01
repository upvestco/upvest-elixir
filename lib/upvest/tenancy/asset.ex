defmodule Upvest.Tenancy.Asset do
  use Upvest.API, [:list]

  def endpoint do
    "/assets/"
  end
end
