defmodule Upvest.PermissionError do
  @moduledoc """
  No permission to access resource
  """
  @type t :: %__MODULE__{}

  defexception type: "permission_error",
               message: nil,
               code: 403
end
