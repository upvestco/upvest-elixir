defmodule Upvest.APIConnectionError do
  @moduledoc """
  Failure to connect to the Upvest API.
  Network issues, timeouts etc
  """
  @type t :: %__MODULE__{}

  defexception type: "api_connection_error",
               message: nil,
               code: nil,
               details: nil
end
