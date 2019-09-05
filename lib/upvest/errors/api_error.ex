defmodule Upvest.APIError do
  @moduledoc """
  API errors cover any other type of problem, such as:
  * Internal Server Error: Something went wrong on Upvest's end.
  * Service Unavailable.
  """

  @type t :: %__MODULE__{}

  defexception type: "api_error", message: nil, code: nil, details: nil
end
