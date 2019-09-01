defmodule Upvest.PermissionError do
  @moduledoc """
  No permission to access resource
  """
  defexception type: "permission_error",
               message: nil,
               code: 403
end
