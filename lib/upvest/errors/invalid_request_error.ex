defmodule Upvest.InvalidRequestError do
  @moduledoc """
  Bad Request: often due to missing a required parameter
  422, Unprocessable entity. The request could not be processed.
  404 - Not found
  """
  @type t :: %__MODULE__{}

  defexception type: "invalid_request_error",
               message: nil,
               code: 400,
               details: nil
end
