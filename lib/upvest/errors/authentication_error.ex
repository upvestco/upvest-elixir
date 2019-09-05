defmodule Upvest.AuthenticationError do
  @moduledoc """
  Unauthorized: missing API key or invalid API key provided.
  """
  @type t :: %__MODULE__{}

  defexception type: "authentication_error",
               message: nil,
               code: 401,
               details: nil
end
