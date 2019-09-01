defmodule Upvest.APIConnectionError do
  @moduledoc """
  Failure to connect to the Upvest API.
  Network issues, timeouts etc
  """
  defexception type: "api_connection_error",
               message: nil,
               code: nil
end
